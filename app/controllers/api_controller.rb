class APIController < ApplicationController
  FORMATS = {
    'text/vnd.lcboapi.v1+tsv' => :tsv,
    'text/vnd.lcboapi.v2+tsv' => :tsv,
    'text/vnd.lcboapi.v1+csv' => :csv,
    'text/vnd.lcboapi.v2+csv' => :csv,
    'application/vnd.api+json'        => :json,
    'application/vnd.lcboapi.v1+json' => :json,
    'application/vnd.lcboapi.v2+json' => :json
  }

  before_filter :set_api_headers, :normalize_vendor_format

  clear_respond_to
  respond_to :json

  protected

  def api_version
    raise NotImplementedError
  end

  def normalize_vendor_format
    return true unless (match = FORMATS[request.format.to_s])
    request.format = match
    true
  end

  def set_api_headers
    response.headers['X-API-Version'] = api_version
    true
  end
end
