class ApplicationController < ActionController::Base

  layout 'application'

  rescue_from \
    GCoder::NoResultsError,
    GCoder::OverLimitError,
    GCoder::GeocoderError,
    QueryHelper::NotFoundError,
    QueryHelper::BadQueryError, with: :render_exception

  before_filter :set_cache_control, if: :cacheable?
  before_filter :set_api_format,    if: :api_request?
  after_filter  :set_jsonp_status,  if: :api_request?

  protected

  def cacheable?
    Rails.env.production?
  end

  def http_status(code)
    path = (Rails.root + 'public' + "#{code}.html").to_s
    render file: path, status: code
    false
  end

  def set_cache_control
    response.etag                   = LCBOAPI.cache_stamp
    response.cache_control[:public] = true
    response.cache_control[:extras] = %W[ s-maxage=#{30.minutes} ]
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
    when request.format.nil?
      render_error :not_found_error,
        "The format you requested is not supported.", 404
      false
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

    if jsonp? && !params[:callback].match(/\A[a-z0-9_]+\Z/i)
      request.format = :json
      render_error :jsonp_error,
        "JSON-P callback (#{params[:callback]}) is not valid, it can only " \
        "contain letters, numbers, and underscores."
    end
  end

  def set_jsonp_status
    response.status = 200 if jsonp?
  end

  def jsonp?
    request.format && request.format.js? && params[:callback].present?
  end

  def query(type)
    QueryHelper.query(type, request, params)
  end

  def render_error(error, message, status = 400)
    unless jsonp?
      response.content_type = 'application/json'
      response.status = status
    end

    h = {}
    h[:result]  = nil
    h[:error]   = error.to_s
    h[:message] = message

    case error
    when 'no_results_error', 'over_limit_error', 'geocoder_error'
      if params[:store_id].present?
        h[:store] = QueryHelper.find(:store, params[:store_id]).as_json
      end

      if params[:product_id].present?
        h[:product] = QueryHelper.find(:product, params[:product_id]).as_json
      end
    end

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
    if jsonp?
      render text: encode_json(data, params[:callback])
    else
      render text: encode_json(data)
    end
  end

  def encode_json(data, callback = nil)
    json = Oj.dump({
      status: response.status,
      message: nil
    }.merge(data), mode: :compat)
    callback ? "#{callback}(#{json});" : json
  end

end
