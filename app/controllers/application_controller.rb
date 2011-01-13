class ApplicationController < ActionController::Base

  layout 'application'

  rescue_from \
    GCoder::NoResultsError,
    GCoder::OverLimitError,
    GCoder::GeocoderError,
    QueryHelper::JsonpError,
    QueryHelper::NotFoundError,
    QueryHelper::BadQueryError, :with => :render_exception

  before_filter :set_cache_control, :if => -> { Rails.env.production? }
  before_filter :set_default_format
  after_filter  :set_status_jsonp,  :if => :api_request?

  protected

  def http_status(code)
    path = (Rails.root + 'public' + "#{code}.html").to_s
    render :file => code, :status => code
    false
  end

  def api_request?
    params[:version] ? true : false
  end

  def json?
    !request.format.csv? &&
    !request.format.tsv? &&
    !request.format.kml? &&
    !request.format.zip?
  end

  def jsonp?
    json? && params[:callback].present?
  end

  def jsonp_callback
    QueryHelper.jsonp_callback(params)
  end

  def set_default_format
    return unless api_request? && json?
    request.format = (jsonp? ? :js : :json)
  end

  def set_cache_control
    response.etag                   = LCBOAPI.cache_stamp
    response.cache_control[:public] = true
    response.cache_control[:extras] = %W[ s-maxage=#{1.day} ]
  end

  def set_status_jsonp
    response.status = 200 if jsonp?
  end

  def query(type)
    QueryHelper.query(type, request, params)
  end

  def render_exception(error)
    h = {}
    h[:result]  = nil
    h[:error]   = error.class.to_s.demodulize.underscore
    h[:message] = error.message
    response.status = case error
      when QueryHelper::NotFoundError
        404
      else
        400
      end
    render_json(h)
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
