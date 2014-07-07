class User < ActiveRecord::Base
  SESSION_TTL = 3.weeks

  has_many :keys, dependent: :destroy

  before_create :generate_verification_token
  after_create :deliver_welcome_message
  after_update :verify_email_address, if: :email_changed?

  def self.challenge(params)
    email    = params[:email]
    password = params[:password]

    return if email.blank? || password.blank?

    email.downcase!

    if (found = where('email IS NOT NULL AND LOWER(email) = ?', email).first)
      found.password == password
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
    id = Base62.uuid_decode(token.key)
    return unless user = where(id: id).first

    if SecureCompare.compare(user.auth_token, token.secret)
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
    id = Base62.uuid_decode(token.key)
    return unless user = where(id: id).first

    if SecureCompare.compare(user.verification_token, token.secret)
      user.update_attribute(:verification_token, nil)
      user
    else
      nil
    end
  end

  def id62
    Base62.uuid_encode(id)
  end

  def password
    BCrypt::Password.new(password_digest)
  end

  def email_changed?
    @email_changed ? true : false
  end

  def pending_email=(val)
    @email_changed = true if persisted?
    write_attribute :pending_email, val
  end

  def generate_auth_token
    token = Token.generate(:auth, key: id62)
    self.auth_token = token.secret
    token
  end

  def generate_verification_token
    token = Token.generate(:verification, key: id62)
    self.verification_token = token.secret
    token
  end

  def verification_token
    Token.new(id62, read_attribute(:verification_token), :verification).to_s
  end

  def auth_token
    Token.new(id62, read_attribute(:auth_token), :auth).to_s
  end

  def generate_session_token
    token = Token.generate(:session)
    json = %|{"user_id":"#{id}","secret":"#{token.secret}"}|
    $redis.setex("sessions:#{token.key}", SESSION_TTL, json)
    token
  end

  private

  def deliver_welcome_message
    UserMailer.welcome_message(id).deliver
  end
end
