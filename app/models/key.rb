class Key < ActiveRecord::Base
  belongs_to :user

  before_validation :generate_secret, on: :create

  validates :user_id, presence: true
  validates :secret,  presence: true

  def self.lookup(raw_token)
    return unless token = Token.parse(raw_token)
    return unless token.is?(:api)
    return unless key = where(id: token[:key_id]).first

    SecureCompare.compare(key.secret, token[:secret]) ? key : nil
  rescue ActiveRecord::StatementInvalid
    nil
  end

  def token
    @token ||= Token.new(:api, key_id: id, user_id: user_id, secret: secret)
  end

  def to_s
    token.to_s
  end

  def to_param
    to_s
  end

  private

  def generate_secret
    self.secret = Token.generate_secret
  end
end
