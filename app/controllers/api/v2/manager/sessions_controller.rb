class API::V2::Manager::SessionsController < API::V2::Manager::ManagerController
  skip_before_filter :authenticate!, only: :create

  def show
  end

  def create
    if (u = User.challenge(params[:session]))
      render json: { session: {
        token:      u.generate_session_token.to_i,
        expires_at: Time.now + User::SESSION_TTL
      } }, status: 200
    else
      render json: { errors: {
        base: ['could not log you in with that email and password']
      } }, status: 422
    end
  end

  def update
    token = Token.parse(auth_token)
    
  end

  def destroy
  end
end
