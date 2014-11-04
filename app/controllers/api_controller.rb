class APIController < ApplicationController
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

  def jsonp?
    (request.format && request.format.js?) && params[:callback].present?
  end

  def rate_limit(max, uniq = nil)
    uniq    ||= request.ip
    keyspace  = "#{Rails.env}:ratelimit:count:#{uniq}"
    count     = $redis.incr(keyspace).to_i

    if count == 1
      $redis.expire(keyspace, 1.hour)
    end

    ttl = $redis.ttl(keyspace).to_i + 1

    response.headers['X-Rate-Limit-Max']   = max
    response.headers['X-Rate-Limit-Count'] = count
    response.headers['X-Rate-Limit-Reset'] = ttl

    if count > max
      render_error \
        code:   'rate_limited',
        title:  'Rate limit reached',
        detail: I18n.t('rate_limited', max: max, ttl: ttl),
        status: 403
    else
      true
    end
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
