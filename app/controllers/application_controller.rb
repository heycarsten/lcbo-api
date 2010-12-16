class ApplicationController < ActionController::Base

  layout 'application'

  protected

  def render_resource(data, options = {})
    h = {}
    h[:json]     = contain_resource(data, options)
    h[:callback] = params[:callback] if params[:callback]
    if 2 == params[:version]
      response.content_type = 'application/vnd.lcboapi.v2+json'
    else
      response.content_type = 'application/json'
    end
    render(h)
  end

  def contain_resource(data, options = {})
    { :response => data.as_json,
      :status => response.status,
      :message => nil
    }.merge(options)
  end

end
