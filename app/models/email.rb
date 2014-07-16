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
  after_create      :send_verification, if: :has_delivery?

  def email_contact
    "#{user.name} <#{address}>"
  end

  def address=(val)
    write_attribute :address, val ? val.downcase : nil
  end

  def self.verify(raw_token)
    return unless token = Token.parse(raw_token)
    return unless token.email_verification?
    return unless (email = unverified.where(id: token.id).first)

    if SecureCompare.compare(email.verification_secret, token.secret)
      email.verify!
    else
      nil
    end
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
    Token.generate(:email_verification, id: id, secret: verification_secret)
  end

  def has_delivery?
    @delivery ? true : false
  end

  def save_with_verification_message
    @delivery = :verification
    save
  end

  def save_with_welcome_verification_message
    @delivery = :welcome_verification
    save
  end

  private

  def send_verification
    case @delviery
    when :welcome_verification
      EmailMailer.welcome_verification_message(id).deliver
    when :verification
      EmailMailer.verification_message(id).deliver
    end

    @delivery = nil
    true
  end

  def generate_verification_secret
    self.verification_secret = Token.generate(:email_verification).secret
  end
end
