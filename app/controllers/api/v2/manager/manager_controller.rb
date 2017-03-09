class API::V2::Manager::ManagerController < API::V2::APIController
  skip_before_action :enforce_access_key!

  serialization_scope nil

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

  def authenticate!
    current_user ? true : not_authorized
  end

  def unauthenticate!
    current_user.destroy_session_token(auth_token)
    @current_user = nil
  end

  def render_session(token, ttl = User::SESSION_TTL)
    render json: { session: {
      token:      token.to_s,
      expires_at: Time.now + ttl
    } }, status: 200, serializer: nil
  end

  def render_error(error)
    status = error.delete(:status) || raise(ArgumentError, 'must supply :status')

    error[:code]   || raise(ArgumentError, 'must supply :code')
    error[:detail] || raise(ArgumentError, 'must supply :detail')

    render json: {
      error: error
    }, status: status, callback: params[:callback]

    false
  end
end
