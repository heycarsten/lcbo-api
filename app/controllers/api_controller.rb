class APIController < ApplicationController
  before_filter :set_api_headers

  clear_respond_to
  respond_to :json, :js

  protected

  def api_version
    raise NotImplementedError
  end

  def set_api_headers
    response.headers['X-API-Version'] = api_version
    true
  end
end
