class ApplicationController < ActionController::Base

  layout 'application'

  rescue_from \
    GCoder::NoResultsError,
    GCoder::OverLimitError,
    GCoder::GeocoderError,
    QueryHelper::NotFoundError,
    QueryHelper::BadQueryError, :with => :render_exception

  before_filter :set_cache_control, :if => -> { Rails.env.production? }
  after_filter  :set_status_jsonp,  :if => :api_request?

  protected

  def status(code)
    path = (Rails.root + 'public' + "#{code}.html").to_s
    render :file => code, :status => code
    false
  end

  def api_request?
    params[:version] ? true : false
  end

  def jsonp?
    request.format.json? && params[:callback].present?
  end

  def set_cache_control
    response.etag                   = LCBOAPI.cache_stamp
    response.cache_control[:public] = true
    response.cache_control[:extras] = %W[ s-maxage=#{1.day} ]
  end

  def set_status_jsonp
    response.status = 200 if jsonp?
  end

  def QueryHelper(type)
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

  def render_json(data, options = {})
    h = {}
    h[:json] = wrap_json(data)
    h[:callback] = params[:callback] if jsonp?
    response.content_type = 'application/json'
    render(h.merge(options))
  end

  def wrap_json(data, options = {})
    { :status => response.status, :message => nil }.
      merge(data).
      merge(options)
  end

end
