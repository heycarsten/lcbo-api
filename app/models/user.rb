class User < ActiveRecord::Base
  SESSION_TTL = 3.weeks
  NAME_RE  = /\A[[:alpha:] '\-]+\Z/u

  has_many :keys,   dependent: :destroy
  has_many :emails, dependent: :destroy

  before_create :generate_auth_secret, :generate_verification_secret
  before_save   :set_password_digest, if: :password_changed?

  after_create  :welcome_and_update_email, if: :email_changed?
  after_update  :update_email,  if: :email_changed?

  validates :password,
    presence: true,
    length: { minimum: 6, maximum: 200 },
    if: :password_changed?

  validates :name,
    presence: true,
    format: {
      with: NAME_RE,
      message: I18n.t('user.invalid_name')
    }

  validate :validate_email_presence, if: :new_record?
  validate :validate_email,          if: :email_changed?

  attr_reader :new_email

  def self.challenge(params)
    email    = params[:email].to_s.downcase
    password = params[:password]

    return if email.blank? || password.blank?

    if (found = where('email IS NOT NULL AND LOWER(email) = ?', email).first)
      return if (password_digest = found.password_digest).blank?
      password_digest == password ? found : nil
    else
      nil
    end
  end

  def self.lookup(raw_token)
    return unless token = Token.parse(raw_token)

    if token.session?
      lookup_session_token(token)
    elsif token.auth?
      lookup_auth_token(token)
    elsif token.verification?
      lookup_verificaiton_token(token)
    end
  end

  def self.lookup_auth_token(token)
    return unless user = where(id: token.id).first

    if SecureCompare.compare(user.auth_secret, token.secret)
      user
    else
      nil
    end
  end

  def self.lookup_session_token(token)
    return unless json = $redis.get("sessions:#{token.key}")

    payload = JSON.parse(json)

    if SecureCompare.compare(token.secret, json['secret'])
      where(id: json['user_id']).first
    else
      nil
    end
  end

  def self.lookup_verification_token(token)
    return unless user = where(id: token.id).first

    if SecureCompare.compare(user.verification_secret, token.secret)
      user.generate_verification_secret
      user
    else
      nil
    end
  end

  def password_changed?
    return true if new_record?
    @password_changed ? true : false
  end

  def password=(val)
    @password_changed = true
    @password = val
  end

  def password
    @password
  end

  def password_digest
    BCrypt::Password.new(read_attribute(:password_digest))
  end

  def first_name
    name.present? ? name.split(' ')[0] : nil
  end

  def email_contact
    "#{name} <#{email}>"
  end

  def email_changed?
    return true if new_record?
    @email_changed ? true : false
  end

  def email=(val)
    @email_changed = true
    @new_email = emails.build(address: val)
  end

  def generate_auth_secret
    self.auth_secret = Token.generate(:auth).secret
  end

  def generate_verification_secret
    self.verification_secret = Token.generate(:verification).secret
  end

  def verification_token
    Token.generate(:verification, id: id, secret: verification_secret)
  end

  def auth_token
    Token.generate(:auth, id: id, secret: auth_secret)
  end

  def generate_session_token
    token = Token.generate(:session)
    json = %|{"user_id":"#{id}","secret":"#{token.secret}"}|
    $redis.setex("sessions:#{token.key}", SESSION_TTL, json)
    token
  end

  def assign_email_address!(email)
    e = Email.verified.where(address: email).first!
    write_attribute :email, e.address
    save!
  end

  private

  def validate_email_presence
    return true unless new_record?
    return true if @new_email
    errors.add :email, 'must be provided'
  end

  def validate_email
    return true unless @new_email
    return true if @new_email.valid?
    @new_email.errors[:address].each do |error|
      errors.add(:email, error)
    end
    true
  end

  def welcome_and_update_email
    return unless @new_email
    @new_email.save_with_welcome_verification_message
  end

  def update_email
    return unless @new_email
    @new_email.save_with_verification_message
  end

  def set_password_digest
    return true unless password_changed?
    self.password_digest = BCrypt::Password.create(@password)
  end
end
