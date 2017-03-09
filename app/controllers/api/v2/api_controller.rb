class API::V2::APIController < APIController
  VERSION  = 2
  PER      = 50

  rescue_from \
    GCoder::NoResultsError,
    GCoder::OverLimitError,
    GCoder::GeocoderError, with: :render_exeption

  rescue_from NotAuthorizedError, with: :not_authorized

  before_action \
    :verify_request!,
    :enforce_access_key!,
    :authenticate!, except: :preflight_cors

  def context
    { current_key: current_key }
  end

  protected

  def authenticate!
    current_key ? true : not_authorized
  end

  def api_version
    VERSION
  end

  def render_exception(e)
    render_error \
      status: 400,
      code:   error.class.to_s.demodulize.underscore.sub('_error', ''),
      title:  error.class.to_s.demodulize.titleize,
      detail: error.message
  end

  def render_error(attrs)
    attrs[:status] ||= '401'
    error = JSONAPI::Error.new(attrs)
    render json: { errors: [error] }, status: attrs[:status]
  end
end
