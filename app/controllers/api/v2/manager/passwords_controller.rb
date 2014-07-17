class API::V2::Manager::PasswordsController < API::V2::Manager::ManagerController
  skip_before_filter :authenticate!, only: [:create, :update]
  before_filter :find_user, only: :update

  def create
    if (user = User.verified.where(email: params[:email].to_s.downcase).first)
      UserMailer.change_password_message(user.id).deliver
      render text: '', status: 204
    else
      render json: { errors: {
        email: ['is not associated with an active account']
      } }, status: 422
    end
  end

  def update
    if @user.update(password: params[:password])
      @user.generate_verification_secret
      @user.save!
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
        message: 'new password link is invalid or was already used'
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
