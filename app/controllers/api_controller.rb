class APIController < ApplicationController
  MAX_DEV_IPS       = 3
  RATE_LIMIT_WEB    = 1200
  RATE_LIMIT_NATIVE = 2400
  BASIC_AUTH        = ActionController::HttpAuthentication::Basic

  LOOPBACKS = %w[
    0.0.0.0
    127.0.0.1
    localhost
  ]

  CORS_HEADERS = {
    'Access-Control-Allow-Origin'  => '*',
    'Access-Control-Allow-Methods' => 'GET',
    'Access-Control-Allow-Headers' => %w[
      Accept
      Authorization
    ].join(', '),
    'Access-Control-Expose-Headers' => %w[
      X-Rate-Limit-Count
      X-Rate-Limit-Max
      X-Rate-Limit-Reset
    ].join(', ')
  }

  class NotAuthorizedError < StandardError; end

  before_action \
    :set_api_headers,
    :record_api_hit

  after_action \
    :twerk_response_for_jsonp,
    :add_cors_headers

  clear_respond_to
  respond_to :json, :js

  def preflight_cors
    head :ok
  end

  protected

  def verify_request!
    return true unless current_key

    if current_key[:kind] != 'web_client' || current_key[:domain].blank?
      params.delete(:callback)
      return true
    end

    @enable_cors = true

    if origin && (LOOPBACKS.include?(origin) || origin.include?(current_key[:domain]))
      true
    else
      render_error \
        status: 403,
        code: 'bad_origin',
        detail: I18n.t('bad_origin')
    end
  end

  def add_cors_headers(allow_origin = '*')
    return true unless @enable_cors
    headers.merge!(CORS_HEADERS)
    headers['Access-Control-Allow-Origin'] = allow_origin
  end

  def origin
    @origin ||= begin
      origin = (request.headers['Origin'] || request.headers['Referer'])

      return if origin.blank?

      origin.downcase!

      if origin == 'null'
        origin = 'http://localhost'
      end

      uri = URI.parse(origin)

      case uri.scheme
      when 'http', 'https'
        uri.host
      else
        nil
      end
    rescue URI::InvalidURIError
      nil
    end
  end

  # This POS returns in any context and is a POS.
  def default_serializer(resource)
    nil
  end

  def get_auth_token
    header = request.headers['Authorization']

    case header
    when /\AToken /i
      return header
    when /\ABasic /i
      _, token = BASIC_AUTH.user_name_and_password(request)
      return token
    else
      params[:access_key]
    end
  end

  def auth_token
    @auth_token ||= Token.parse(get_auth_token)
  end

  def current_user
    @current_user ||= User.lookup(auth_token)
  end

  def current_key
    @current_key ||= Key.lookup(auth_token)
  end

  def account_info
    @account_info ||= begin
      user_id = if current_key
        current_key[:user_id]
      elsif current_user
        current_user.id
      end

      begin
        User.redis_load(user_id)
      rescue ActiveRecord::RecordNotFound
        raise NotAuthorizedError
      end
    end
  end

  def jsonp?
    (request.format && request.format.js?) && params[:callback].present?
  end

  def enforce_access_key!
    return true unless current_key

    return false unless enforce_request_pool!
    return false unless enforce_restrictions!
    return false unless enforce_max_clients!
    return false unless enforce_rate_limit!

    true
  end

  def enforce_restrictions!
    account_info[:has_ssl]
    account_info[:has_cors]
    true
  end

  def enforce_max_clients!
    key_id     = current_key[:id]
    kind       = current_key[:kind]
    in_devmode = current_key[:in_devmode] ? true : false
    max        = account_info[:max_dev_ips] || MAX_DEV_IPS
    redis_key  = Key.redis_hourly_ips_log_key(key_id)

    return true unless kind == 'web_client' && in_devmode

    result = $redis.multi do
      $redis.pfadd(redis_key, request.remote_ip)
      $redis.ttl(redis_key)
      $redis.pfcount(redis_key)
    end

    is_new = result[0]
    ttl    = result[1].to_i
    count  = result[2].to_i

    if ttl == -1
      $redis.expire(redis_key, 1.hour)
    end

    response.headers['X-Client-Limit-Max']   = max
    response.headers['X-Client-Limit-Count'] = count
    response.headers['X-Client-Limit-TTL']   = ttl

    if (count > max) && is_new
      render_error \
        status: 403,
        code: 'too_many_sessions',
        title: 'Maximum client sessions reached',
        detail: I18n.t('too_many_sessions', max: max, ttl: ttl)

      return false
    end

    true
  end

  def enforce_rate_limit!
    key_id     = current_key[:id]
    kind       = current_key[:kind]
    in_devmode = current_key[:in_devmode] ? true : false
    redis_key  = Key.redis_ip_requests_per_hour_key(key_id, request.remote_ip)

    return true unless (kind == 'web_client' && !in_devmode) || kind == 'native_client'

    # Enforce max requests per hour limit
    count = $redis.incr(redis_key).to_i
    max   = kind == 'web_client' ? RATE_LIMIT_WEB : RATE_LIMIT_NATIVE

    if count == 1
      $redis.expire(redis_key, 1.hour)
    end

    ttl = $redis.ttl(redis_key).to_i + 1

    response.headers['X-Rate-Limit-Max']   = max
    response.headers['X-Rate-Limit-Count'] = count
    response.headers['X-Rate-Limit-TTL']   = ttl

    if count > max
      render_error \
        code:   'rate_limited',
        title:  'Rate limit reached',
        detail: I18n.t('rate_limited', max: max, ttl: ttl),
        status: 403

      return false
    end

    true
  end

  def record_api_hit
    return true unless current_key
    return true if @current_hit

    now     = Time.now.utc
    cycle   = now.strftime('%Y-%m')
    member  = now.strftime('%Y-%m-%d')
    key_id  = current_key[:id]
    user_id = current_key[:user_id]

    user_total = nil
    key_total  = nil

    $redis.pipelined do
      user_total = $redis.incr User.redis_cycle_total_requests_key(user_id, cycle)
      $redis.zincrby User.redis_cycle_daily_request_totals_key(user_id, cycle), 1, member
      $redis.sadd    User.redis_cycles_key(user_id), cycle
      $redis.incr    User.redis_total_requests_key(user_id)

      key_total = $redis.incr Key.redis_cycle_total_requests_key(key_id, cycle)
      $redis.zincrby Key.redis_cycle_daily_request_totals_key(key_id, cycle), 1, member
      $redis.sadd    Key.redis_cycles_key(key_id), cycle
      $redis.incr    Key.redis_total_requests_key(key_id)
    end

    @current_hit = {
      user_total: user_total.value.to_i,
      key_total: key_total.value.to_i
    }

    true
  end

  def current_hit
    @current_hit
  end

  def enforce_request_pool!
    now   = Time.now
    max   = account_info[:request_pool_size]
    count = current_hit[:user_total]
    ttl   = now.end_of_month.to_i - now.to_i

    response.headers['X-Request-Pool-Size']  = max
    response.headers['X-Request-Pool-Count'] = count
    response.headers['X-Request-Pool-TTL']   = ttl

    if count > max
      render_error \
        code:   'too_many_requests',
        title:  'Exceeded monthly request pool',
        detail: I18n.t('too_many_requests', max: max),
        status: 403

      return false
    end

    true
  end

  def api_version
    raise NotImplementedError
  end

  def twerk_response_for_jsonp
    return true unless jsonp?
    response.headers['Content-Type'] = 'text/javascript'
    response.status = 200
    true
  end

  def set_api_headers
    response.headers['X-API-Version'] = api_version
    true
  end

  def render_error(error)
    status = error.delete(:status) || raise(ArgumentError, 'must supply :status')

    error[:code]   || raise(ArgumentError, 'must supply :code')
    error[:detail] || raise(ArgumentError, 'must supply :detail')

    render json: {
      error: error
    }, status: status, callback: params[:callback]

    false
  end

  def not_authorized
    render_error \
      code:   'unauthorized',
      title:  'Unauthorized',
      detail: I18n.t('unauthorized'),
      status: 401
  end
end
