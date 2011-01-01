class ApplicationController < ActionController::Base

  layout 'application'

  rescue_from GCoder::NoResultsError,     :with => :render_exception
  rescue_from GCoder::OverLimitError,     :with => :render_exception
  rescue_from GCoder::GeocoderError,      :with => :render_exception
  rescue_from QueryHelper::BadQueryError, :with => :render_exception

  protected

  def render_exception(error)
    h = {}
    h[:result]  = []
    h[:error]   = error.class.to_s.demodulize.underscore
    h[:message] = error.message
    response.status = 400
    render_data decorate_data(h)
  end

  def render_query(type, params)
    render_data(decorate_data(QueryHelper.query(type, request, params)))
  end

  def render_resource(data, options = {})
    render_data decorate_data(data.as_json, options)
  end

  def render_data(data, options = {})
    h = {}
    h[:json] = data
    h[:callback] = params[:callback] if params[:callback]
    case
    when params[:raw]
      response.content_type = 'text/json'
    else
      response.content_type = 'application/json'
    end
    render(h.merge(options))
  end

  def decorate_data(data, options = {})
    { :status => response.status, :message => nil }.
      merge(data).
      merge(options)
  end

end
