class EmailMailer < ApplicationMailer
  def welcome_verification_message(email_id)
    @email = Email.find(email_id)

    mail \
      subject: 'Welcome to LCBO API',
      to: @email.email_contact
  end

  def verification_message(email_id)
    @email = Email.find(email_id)

    mail \
      subject: '[LCBO API] Please verify this email address',
      to: @email.email_contact
  end
end
