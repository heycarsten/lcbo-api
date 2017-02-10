class API::V2::Manager::SessionsController < API::V2::Manager::ManagerController
  skip_before_action :authenticate!, only: :create

  def show
    ttl = current_user.session_token_ttl(auth_token)
    render_session(auth_token, ttl)
  end

  def create
    if (user = User.challenge(params[:session]))
      render_session(user.generate_session_token)
    else
      render_error \
        code:   'invalid',
        title:  'Unable to log in',
        detail: 'could not log in with that email and password',
        status: 422
    end
  end

  def update
    current_user.refresh_session_token(auth_token)
    render_session(auth_token)
  end

  def destroy
    unauthenticate!
    render plain: '', status: 204
  end
end
