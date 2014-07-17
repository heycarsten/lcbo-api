class API::V2::Manager::ManagerController < API::V2::APIController
  protected

  def auth_token
    @auth_token ||= Token.parse(request.headers['X-Auth-Token'])
  end

  def authenticate!
    return true if current_user
    not_authorized
  end

  def unauthenticate!
    current_user.destroy_session_token(auth_token)
    @current_user = nil
  end

  def current_user
    @current_user ||= User.lookup(auth_token)
  end

  def render_session(token, ttl = User::SESSION_TTL)
    render json: { session: {
      token:      token.to_s,
      expires_at: Time.now + ttl
    } }, status: 200
  end
end
