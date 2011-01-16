class ApplicationController < ActionController::Base

  layout 'application'

  rescue_from \
    GCoder::NoResultsError,
    GCoder::OverLimitError,
    GCoder::GeocoderError,
    QueryHelper::NotFoundError,
    QueryHelper::BadQueryError, :with => :render_exception

  before_filter :set_cache_control, :if => :cacheable?
  before_filter :set_api_format,    :if => :api_request?

  protected

  def cacheable?
    Rails.env.production?
  end

  def http_status(code)
    path = (Rails.root + 'public' + "#{code}.html").to_s
    render :file => code, :status => code
    false
  end

  def set_cache_control
    response.etag                   = LCBOAPI.cache_stamp
    response.cache_control[:public] = true
    response.cache_control[:extras] = %W[ s-maxage=#{1.day} ]
  end

  def api_request?
    params[:version] ? true : false
  end

  def default_format?
    !request.format.csv? &&
    !request.format.tsv? &&
    !request.format.kml? &&
    !request.format.zip? &&
    !request.format.js? &&
    !request.format.json?
  end

  def set_api_format
    case
    when request.format.js? && params[:callback].blank?
      render_error :jsonp_error,
        "JSON-P (.js) can not be requested without specifying a callback " \
        "parameter. Try something like: #{request.path}?callback={your " \
        "callback function}"
      false
    when request.format.json? && params[:callback].present?
      render_error :jsonp_error,
        "JSON format can not be requested with a callback parameter, if you " \
        "want JSON-P then either drop the .json extension or use the .js " \
        "extension instead of .json: #{request.fullpath.sub('.json', '.js')}"
      false
    when default_format? && params[:callback].present?
      request.format = :js
    when default_format?
      request.format = :json
    end
  end

  def jsonp?
    request.format.js? && params[:callback].present?
  end

  def query(type)
    QueryHelper.query(type, request, params)
  end

  def error_as_json(error, message, status = 400)
    response.content_type = 'application/json'
    response.status = status
    h = {}
    h[:result]  = nil
    h[:error]   = error.to_s
    h[:message] = message
    h
  end

  def render_error(*args)
    render_json(error_as_json(*args))
  end

  def render_exception(error)
    render_error(
      error.class.to_s.demodulize.underscore,
      error.message,
      (error.is_a?(QueryHelper::NotFoundError) ? 404 : 400)
    )
  end

  def render_jsonp(data, callback)
    render :text => begin
      if callback && callback.match(/\A[a-z0-9_]+\Z/i)
        response.status = 200
        encode_json(data, callback)
      else
        encode_json(
          error_as_json(:jsonp_error,
            "JSON-P callback (#{callback}) is not valid, it can only contain " \
            "letters, numbers, and underscores."
          )
        )
      end
    end
  end

  def render_json(data)
    if jsonp?
      render_jsonp(data, params[:callback])
    else
      render :text => encode_json(data)
    end
  end

  def encode_json(data, callback = nil)
    json = Yajl::Encoder.encode({
      :status => response.status,
      :message => nil
    }.merge(data))
    callback ? "#{callback}(#{json});" : json
  end

end
