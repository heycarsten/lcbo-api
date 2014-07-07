class API::V2::APIController < APIController
  VERSION  = 2
  RATE_MAX = 1800

  before_filter :rate_limit!
  before_filter :authenticate!

  protected

  def api_version
    VERSION
  end

  def api_key
    headers['X-API-Key'] || params[:api_key]
  end

  def render_error(message, opts = { status: 400 })
    render({
      json: { message: message }
    }.merge(opts))
    false
  end

  def not_authorized
    render_error(I18n.t('unauthorized'), status: 401)
    false
  end

  def rate_limit!
    count_key = "#{api_key || request.ip}:ratelimit:count"
    max_key   = "#{api_key}:ratelimit:max"
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
      render_error(I18n.t('rate_limited', max: max, ttl: ttl), status: 403)
      return false
    end

    true
  end

  def authenticate!
    not_authorized
  end
end
