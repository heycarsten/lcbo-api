class API::V2::Manager::VerificationsController < API::V2::Manager::ManagerController
  skip_before_filter :authenticate!, only: :update

  def update
    if (user = lookup_user_by_token(params[:token]))
      if current_user
        render_session(auth_token, current_user.session_token_ttl(auth_token))
      else
        render_session(user.generate_session_token)
      end
    else
      render json: {
        messsage: 'verification link is invalid or was already used'
      }, status: 404
    end
  end

  private

  def lookup_user_by_token(raw_token)
    return unless token = Token.parse(raw_token)

    if token.email_verification?
      Email.verify(token).try(:user)
    else
      nil
    end
  end
end
