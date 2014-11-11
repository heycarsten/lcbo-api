class APIController < ApplicationController
  MAX_DEV_IPS       = 3
  RATE_LIMIT_WEB    = 2200
  RATE_LIMIT_NATIVE = 3600

  before_filter :set_api_headers
  after_filter :twerk_response_for_jsonp

  clear_respond_to
  respond_to :json, :js

  protected

  # This POS returns in any context and is a POS.
  def default_serializer(resource)
    nil
  end

  def access_key
    @access_key ||= Token.parse(request.headers['X-Access-Key'] || params[:access_key])
  end

  def auth_token
    @auth_token ||= Token.parse(request.headers['Authorization'])
  end

  def current_user
    @current_user ||= User.lookup(auth_token)
  end

  def current_key
    @current_key ||= Key.lookup(access_key)
  end

  def account_info
    @account_info ||= begin
      user_id = if current_key
        current_key[:user_id]
      elsif current_user
        current_user.id
      end

      User.redis_load(user_id)
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
    rdbkey     = "#{Rails.env}:key:#{key_id}:ip_log"

    return true unless kind == 'web_client' && in_devmode

    is_new  = $redis.pfadd(rdbkey, request.ip).to_i == 1
    ttl     = $redis.ttl(rdbkey).to_i
    count   = $redis.pfcount(rdbkey).to_i

    if ttl == -1
      $redis.expire(rdbkey, 1.hour)
    end

    if (count > max) && is_new
      render_error \
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
    rdbkey     = "#{Rails.env}:key:#{key_id}:rate_limit:#{request.ip}"

    return true unless (kind == 'web_client' && !in_devmode) || kind == 'native_client'

    # Enforce max requests per hour limit
    count = $redis.incr(rdbkey).to_i
    max   = kind == 'web_client' ? RATE_LIMIT_WEB : RATE_LIMIT_NATIVE

    if count == 1
      $redis.expire(rdbkey, 1.hour)
    end

    ttl = $redis.ttl(rdbkey).to_i + 1

    response.headers['X-Rate-Limit-Max']       = max
    response.headers['X-Rate-Limit-Count']     = count
    response.headers['X-Rate-Limit-Reset-TTL'] = ttl

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

  def enforce_request_pool!
    now     = Time.now
    month   = "#{now.year}-#{now.month}"
    ttl     = now.end_of_month.to_i - now.to_i
    user_id = current_key[:user_id]
    max     = account_info[:request_pool_size]
    rdbkey  = "#{Rails.env}:users:#{user_id}:pool_count"

    count = $redis.zincrby(rdbkey, 1, month).to_i

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
