class Email < ActiveRecord::Base
  EMAIL_RE = /\A[^@]+@[^@]+\Z/

  belongs_to :user

  validates :address,
    presence:   true,
    uniqueness: true,
    length:     { minimum: 6, maximum: 200 },
    format:     { with: EMAIL_RE, message: I18n.t('email.invalid_address') }

  scope :unverified, -> { where(is_verified: false) }
  scope :verified,   -> { where(is_verified: true) }

  before_validation :generate_verification_secret, on: :create

  def email_contact
    "#{user.name} <#{address}>"
  end

  def address=(val)
    write_attribute :address, val ? val.downcase : nil
  end

  def self.verify(raw_token)
    return unless token = Token.parse(raw_token)
    return unless token.is?(:email)
    return unless (email = unverified.where(id: token[:email_id]).first)

    if SecureCompare.compare(email.verification_secret, token[:secret])
      email.verify!
    else
      nil
    end

  rescue ActiveRecord::StatementInvalid
    nil
  end

  def verify!
    transaction do
      if (old = Email.where(address: user.email).first)
        old.destroy!
      end

      update!(is_verified: true)
      user.assign_email_address!(address)
    end

    self
  end

  def verification_token
    Token.new(:email, email_id: id, secret: verification_secret)
  end

  def save_with_verification_message
    return false unless save
    EmailMailer.verification_message(id).deliver
    true
  end

  def save_with_welcome_verification_message
    return false unless save
    EmailMailer.welcome_verification_message(id).deliver
    true
  end

  private

  def generate_verification_secret
    self.verification_secret = Token.generate_secret
  end
end
