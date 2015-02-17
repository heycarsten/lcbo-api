class API::V2::APIController < APIController
  VERSION  = 2
  PER      = 50

  serialization_scope nil

  rescue_from \
    GCoder::NoResultsError,
    GCoder::OverLimitError,
    GCoder::GeocoderError,
    Magiq::Error, with: :render_exception

  rescue_from NotAuthorizedError, with: :not_authorized

  before_action \
    :verify_request!,
    :enforce_access_key!,
    :authenticate!, except: :preflight_cors

  self.responder = Class.new(responder) do
    def json_resource_errors
      errors = []

      resource.errors.each do |field, messages|
        Array(messages).each do |msg|
          errors << { code: 'invalid', path: field, detail: msg }
        end
      end

      { errors: errors }
    end
  end

  protected

  def render_json(json, opts = {})
    render({
      json: json,
      callback: params[:callback],
      serializer: nil
    }.merge(opts))
  end

  def authenticate!
    current_key ? true : not_authorized
  end

  def render_exception(error)
    render_error \
      status: 400,
      code:   error.class.to_s.demodulize.underscore.sub('_error', ''),
      detail: error.message
    false
  end

  def api_version
    VERSION
  end

  def pagination_for(scope)
    return nil if !scope.respond_to?(:next_page)

    { pagination: {
        total_records: scope.total_count,
        total_pages:   scope.total_pages,
        page_size:     scope.limit_value,
        current_page:  scope.current_page,
        prev_page:     scope.prev_page,
        next_page:     scope.next_page
    } }
  end
end
