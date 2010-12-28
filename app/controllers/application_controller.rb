class ApplicationController < ActionController::Base

  layout 'application'

  protected

  def render_query(type, params)
    render_data(decorate_data(QueryHelper.query(type, request, params)))
  end

  def render_resource(data, options = {})
    render_data decorate_data(data.as_json, options)
  end

  def render_data(data, options = {})
    h[:json]     = data
    h[:callback] = params[:callback] if params[:callback]
    if 2 == params[:version]
      response.content_type = 'application/vnd.lcboapi.v2+json'
    else
      response.content_type = 'application/json'
    end
    render(h.merge(options))
  end

  def decorate_data(data, options = {})
    data.
      merge(:status => response.status, :message => nil).
      merge(options)
  end

end
