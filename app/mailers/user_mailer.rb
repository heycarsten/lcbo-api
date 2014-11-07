class UserMailer < ActionMailer::Base
  default from: 'LCBO API <help@lcboapi.com>'

  def change_password_message(user_id)
    @user = User.find(user_id)

    mail \
      subject: '[LCBO API] Change your password',
      to: @user.email_contact
  end
end
