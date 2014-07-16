class API::V2::Manager::SessionsController < API::V2::Manager::ManagerController
  skip_before_filter :authenticate!, only: :create

  def show
    ttl = current_user.session_token_ttl(auth_token)
    render_session(auth_token, ttl)
  end

  def create
    if (user = User.challenge(params[:session]))
      render_session(user.generate_session_token)
    else
      render json: { errors: {
        base: ['could not log you in with that email and password']
      } }, status: 422
    end
  end

  def update
    current_user.refresh_session_token(auth_token)
    render_session(auth_token)
  end

  def destroy
    unauthenticate!
    render text: '', status: 202
  end
end
