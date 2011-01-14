class ApplicationController < ActionController::Base

  layout 'application'

  rescue_from \
    GCoder::NoResultsError,
    GCoder::OverLimitError,
    GCoder::GeocoderError,
    QueryHelper::JsonpError,
    QueryHelper::NotFoundError,
    QueryHelper::BadQueryError, :with => :render_exception

  before_filter :set_cache_control,  :if => -> { Rails.env.production? }
  before_filter :set_api_format,     :if => :api_request?
  after_filter  :set_jsonp_status,   :if => :api_request?

  protected

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

  def jsonp_callback
    QueryHelper.jsonp_callback(params)
  end

  def set_jsonp_status
    response.status = 200 if jsonp?
  end

  def query(type)
    QueryHelper.query(type, request, params)
  end

  def render_error(error, message, status = 400)
    h = {}
    h[:result]  = nil
    h[:error]   = error.to_s
    h[:message] = message
    response.content_type = 'application/json'
    response.status = status
    render_json(h)
  end

  def render_exception(error)
    render_error(
      error.class.to_s.demodulize.underscore,
      error.message,
      (error.is_a?(QueryHelper::NotFoundError) ? 404 : 400)
    )
  end

  def render_json(data)
    render :text => encode_json(data)
  end

  def encode_json(data)
    json = Yajl::Encoder.encode({
      :status => response.status,
      :message => nil
    }.merge(data))
    jsonp? ? "#{jsonp_callback}(#{json});" : json
  end

end
