class API::V2::Manager::PasswordsController < API::V2::Manager::ManagerController
  skip_before_filter :authenticate!, only: :update
  before_filter :find_user, only: :update

  def update
    if @user.update(password: params[:password])
      @user.generate_verification_secret
      render_session @user.generate_session_token
    else
      respond_with @user
    end
  end

  private

  def find_user
    if @user = lookup_user_by_token
      true
    else
      render json: {
        messsage: 'new password link is invalid or was already used'
      }, status: 404
      false
    end
  end

  def lookup_user_by_token
    return unless token = Token.parse(params[:token])
    return unless token.verification?
    User.lookup(token)
  end
end
