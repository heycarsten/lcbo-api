class API::V2::Manager::ManagerController < API::V2::APIController
  protected

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
end
