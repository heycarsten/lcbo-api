class API::V2::Manager::SessionsController < API::V2::Manager::ManagerController
  skip_before_filter :authenticate!, only: :create

  def show
    token = Token.parse(auth_token)
    key   = 'sessions:' + token.key
    ttl   = $redis.ttl(key)
    render_session(token, ttl)
  end

  def create
    if (u = User.challenge(params[:session]))
      render_session(u.generate_session_token.to_s)
    else
      render json: { errors: {
        base: ['could not log you in with that email and password']
      } }, status: 422
    end
  end

  def update
    token = Token.parse(auth_token)
    key   = 'sessions:' + token.key
    $redis.expire(key, User::SESSION_TTL)
    render_session(token)
  end

  def destroy
    unauthenticate!
    render text: '', status: 202
  end

  private

  def render_session(token, ttl = User::SESSION_TTL)
    render json: { session: {
      token:      token.to_s,
      expires_at: Time.now + ttl
    } }, status: 200
  end
end
