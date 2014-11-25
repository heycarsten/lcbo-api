class API::V1::APIController < APIController
  CALLBACK_NAME_RE = /\A[a-z0-9_]+(\.{0,1}[a-z0-9_]+)*\z/i
  VERSION          = 1

  rescue_from \
    GCoder::NoResultsError,
    GCoder::OverLimitError,
    GCoder::GeocoderError,
    V1::QueryHelper::NotFoundError,
    V1::QueryHelper::BadQueryError, with: :render_exception

  before_action \
    :restrict_https!,
    :restrict_cors!,
    :verify_request!,
    :set_api_format

  clear_respond_to

  respond_to :json, :js, :csv, :tsv

  protected

  def restrict_https!
    return true if current_key
    return true unless https?

    render_error :not_authorized,
      "You need an Access Key to use HTTPS on LCBO API, sign up for one " \
      "at https://lcboapi.com/sign-up", 401
  end

  def restrict_cors!
    return true if current_key
    return true if request.headers['Origin'].blank?

    render_error :not_authorized,
      "You need an Access Key to use CORS on LCBO API, sign up for one " \
      "at https://lcboapi.com/sign-up", 401
  end

  def api_version
    VERSION
  end

  def http_status(code)
    path = (Rails.root + 'public' + "#{code}.html").to_s
    render file: path, status: code
    false
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

    if jsonp? && !params[:callback].match(CALLBACK_NAME_RE)
      request.format = :json
      render_error :jsonp_error,
        "JSON-P callback (#{params[:callback]}) is not valid, it can only " \
        "contain letters, numbers, underscores, and dots."
    end
  end

  def query(type)
    V1::QueryHelper.query(type, request, params)
  end

  def render_error(*args)
    if args.first.is_a?(Hash)
      error   = args[0][:code]
      message = args[0][:detail]
      status  = args[0][:status]
    else
      error   = args[0]
      message = args[1]
      status  = args[2] || 400
    end

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
        h[:store] = V1::QueryHelper.find(:store, params[:store_id]).as_json
      end

      if params[:product_id].present?
        h[:product] = V1::QueryHelper.find(:product, params[:product_id]).as_json
      end
    end

    render_json(h)
  end

  def render_exception(error)
    render_error(
      error.class.to_s.demodulize.underscore,
      error.message,
      (error.is_a?(V1::QueryHelper::NotFoundError) ? 404 : 400)
    )
  end

  def render_json(data)
    if jsonp?
      render js: encode_json(data, params[:callback])
    else
      render json: encode_json(data)
    end
  end

  def encode_json(data, callback = nil)
    json = MultiJson.dump({
      status: response.status,
      message: nil
    }.merge(data), mode: :compat)

    callback ? "#{callback}(#{json});" : json
  end
end
