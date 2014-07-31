class APIController < ApplicationController
  RATE_MAX = 1800
  FORMATS = {
    'text/vnd.lcboapi.v1+tsv' => :tsv,
    'text/vnd.lcboapi.v2+tsv' => :tsv,
    'text/vnd.lcboapi.v1+csv' => :csv,
    'text/vnd.lcboapi.v2+csv' => :csv,
    'application/vnd.api+json'        => :json,
    'application/vnd.lcboapi.v1+json' => :json,
    'application/vnd.lcboapi.v2+json' => :json
  }

  before_filter :set_api_headers, :normalize_request_format
  after_filter :normalize_response_format

  clear_respond_to
  respond_to :json, :js

  protected

  def rate_limit!
    uniq      = (auth_token || api_token || request.ip)
    count_key = "#{Rails.env}:ratelimit:count:#{uniq}"
    max_key   = "#{Rails.env}:ratelimit:max:#{uniq}"
    max       = ($redis.get(max_key) || RATE_MAX).to_i
    count     = $redis.incr(count_key).to_i

    if count == 1
      $redis.expire(count_key, 1.hour)
    end

    ttl = $redis.ttl(count_key).to_i + 1

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

  def normalize_request_format
    Rails.logger.info("DAFUQ NIGGA!!!?")

    if (match = FORMATS[request.format.to_s])
      request.format = match
      return true
    end

    if params[:callback].present?
      request.format = :js
      return true
    end

    true
  end

  def normalize_response_format
    return true unless params[:callback].present?
    response.headers['Content-Type'] = 'text/javascript'
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
