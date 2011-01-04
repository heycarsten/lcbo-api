class ApplicationController < ActionController::Base

  layout 'application'

  rescue_from \
    GCoder::NoResultsError,
    GCoder::OverLimitError,
    GCoder::GeocoderError,
    QueryHelper::NotFoundError,
    QueryHelper::BadQueryError, :with => :render_exception

  protected

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
    render_data decorate_data(h)
  end

  def render_query(type, params)
    render_data(
      decorate_data(
        QueryHelper.query(type, request, params)
      )
    )
  end

  def render_resource(data, options = {})
    render_data(
      decorate_data({ :result => data.as_json }, options)
    )
  end

  def render_data(data, options = {})
    response.headers['Cache-Control'] = 'must-revalidate, public, max-age=0'
    response.headers['Etag'] = LCBOAPI.release_id
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
