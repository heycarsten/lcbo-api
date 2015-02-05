class API::V2::Manager::PasswordsController < API::V2::Manager::ManagerController
  skip_before_filter :authenticate!, only: [:create, :update]
  before_filter :find_user, only: :update

  def create
    email = params[:email].to_s.downcase

    if (email.present? && user = User.verified.where(email: email).first)
      UserMailer.change_password_message(user.id).deliver_now
    end

    # Always return success to avoid attack vector
    render text: '', status: 204
  end

  def update
    if @user.update(password: params[:password])
      @user.generate_verification_secret
      @user.save!
      render_session @user.generate_session_token
    else
      respond_with :api, :v2, :manager, @user
    end
  end

  private

  def find_user
    if @user = lookup_user_by_token
      true
    else
      render_error \
        code:   'not_found',
        title:  'Not found',
        detail: 'change password URL is invalid or was already used',
        status: 404
    end
  end

  def lookup_user_by_token
    return unless token = Token.parse(params[:token])
    return unless token.is?(:verification)
    User.lookup(token)
  end
end
