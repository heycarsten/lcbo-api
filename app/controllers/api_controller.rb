class APIController < ApplicationController
  before_filter :set_api_headers

  def set_api_headers
    response.headers['X-API-Version'] = params[:api_version]
    true
  end
end
