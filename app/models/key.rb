class Key < ActiveRecord::Base
  enum usage: [
    :mobile,
    :server,
    :client,
    :plugin,
    :business,
    :consulting,
    :aggregation,
    :curiosity,
    :other
  ]

  belongs_to :user

  before_validation :generate_secret, on: :create

  validates :user_id, presence: true
  validates :secret,  presence: true

  def self.lookup(raw_token)
    return unless token = Token.parse(raw_token)
    return unless token.api?
    return unless key = where(id: token.id).first

    SecureCompare.compare(key.secret, token.secret) ? key : nil
  end

  def token
    @token ||= Token.generate(:api, id: id, secret: secret)
  end

  def to_s
    token.to_s
  end

  def to_param
    to_s
  end

  private

  def generate_secret
    self.secret = Token.generate(:api).secret
  end
end
