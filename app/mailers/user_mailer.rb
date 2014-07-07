class UserMailer < ActionMailer::Base
  default from: 'Carsten Nielsen <heycarsten@gmail.com>'

  def welcome_message(user_id)
    @user = User.find(user_id)
    mail subject: 'Welcome to LCBO API'
  end

  def verification_message(user_id)
    @user = User.find(user_id)
    mail subject: '[LCBO API] Please verify this email address'
  end

  def reset_message(user_id)
    @user = User.find(user_id)
    mail subject: '[LCBO API] Reset your password'
  end
end
