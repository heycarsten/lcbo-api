class APIController < ApplicationController
  before_filter :set_api_headers
  after_filter :twerk_content_type_for_jsonp

  clear_respond_to
  respond_to :json, :js

  protected

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

  def twerk_content_type_for_jsonp
    response.headers['Content-Type'] = 'text/javascript' if jsonp?
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

    render json: { error: error }, status: status

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
