class User < ActiveRecord::Base
  SESSION_TTL = 3.weeks
  NAME_RE     = /\A[[:alpha:] '\-]+\Z/u
  MAX_RATE    = 1000
  TRUTHS      = [1, true, '1', 't', 'true', 'yes']

  has_many :keys,   dependent: :destroy
  has_many :emails, dependent: :destroy

  before_create :generate_auth_secret, :generate_verification_secret
  before_save   :set_password_digest, if: :password_changed?

  after_create  :welcome_and_update_email
  after_update  :update_email,  if: :email_changed?

  validates :password,
    presence: true,
    length: { minimum: 8, maximum: 200 },
    if: :password_given?

  validates :new_password,
    presence: true,
    length: { minimum: 8, maximum: 200 },
    if: :new_password_given?

  validates :name,
    presence: true,
    format: {
      with: NAME_RE,
      message: I18n.t('user.invalid_name')
    }

  validate :validate_password_change, if: :new_password_given?
  validate :validate_email_presence,  if: :new_record?
  validate :validate_email,           if: :email_changed?
  validate :validate_terms_agreement, on: :create

  scope :verified, -> { where.not(email: nil) }

  attr_reader \
    :password,
    :new_password,
    :new_email

  def self.challenge(params)
    email    = params[:email].to_s.downcase
    password = params[:password]

    return if email.blank? || password.blank?

    if (found = verified.where('LOWER(email) = ?', email).first)
      return if (password_digest = found.password_digest).blank?
      password_digest == password ? found : nil
    else
      nil
    end
  end

  def self.lookup(raw_token)
    return unless token = Token.parse(raw_token)

    if token.is?(:session)
      lookup_session_token(token)
    elsif token.is?(:auth)
      lookup_auth_token(token)
    elsif token.is?(:verification)
      lookup_verification_token(token)
    end
  rescue ActiveRecord::StatementInvalid
    nil
  end

  def self.lookup_auth_token(token)
    return unless user = verified.where(id: token[:user_id]).first

    if SecureCompare.compare(user.auth_secret, token[:secret])
      user
    else
      nil
    end
  end

  def self.lookup_session_token(token)
    return unless json = $redis.get(redis_session_key(token))
    payload = JSON.parse(json)

    if SecureCompare.compare(token[:secret], payload['secret'])
      where(id: payload['user_id']).first
    else
      nil
    end
  end

  def self.lookup_verification_token(token)
    return unless user = where(id: token[:user_id]).first

    if SecureCompare.compare(user.verification_secret, token[:secret])
      user
    else
      nil
    end
  end

  def self.redis_session_key(token)
    "#{Rails.env}:sessions:#{token[:user_id]}"
  end

  def does_agree_to_terms=(val)
    @does_agree_to_terms = TRUTHS.include?(val)
  end

  def max_rate
    MAX_RATE
  end

  def password_changed?
    return true if new_record?
    @password_changed ? true : false
  end

  def password_given?
    @password_given ? true : false
  end

  def password=(val)
    @password_given = true
    @password_changed = true
    @password = val
  end

  def new_password_given?
    @new_password_given ? true : false
  end

  def new_password=(val)
    @new_password_given = true
    @new_password = val
    self.password = val
    @password_given = false
  end

  def current_password=(val)
    @current_password = val
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
    self.auth_secret = Token.generate_secret
  end

  def generate_verification_secret
    self.verification_secret = Token.generate_secret
  end

  def verification_token
    Token.new(:verification, user_id: id, secret: verification_secret)
  end

  def auth_token
    Token.new(:auth, user_id: id, secret: auth_secret)
  end

  def generate_session_token
    token = Token.generate(:session, user_id: id)
    json = %|{"user_id":"#{id}","secret":"#{token[:secret]}"}|
    $redis.setex(redis_session_key(token), SESSION_TTL, json)
    token
  end

  def session_token_ttl(token)
    $redis.ttl(redis_session_key(token))
  end

  def refresh_session_token(token)
    $redis.expire(redis_session_key(token), User::SESSION_TTL)
  end

  def destroy_session_token(token)
    $redis.del(redis_session_key(token))
  end

  def assign_email_address!(email)
    e = Email.verified.where(address: email).first!
    write_attribute :email, e.address
    save!
  end

  private

  def redis_session_key(token)
    self.class.redis_session_key(token)
  end

  def validate_terms_agreement
    return true if persisted?
    return true if @does_agree_to_terms

    errors.add :does_agree_to_terms, 'sign up requires that you agree to the TOS'
  end

  def validate_password_change
    return true unless new_password_given?
    return true if password_digest == @current_password.to_s

    errors.add :current_password, 'is not correct'
  end

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
