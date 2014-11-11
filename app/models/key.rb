class Key < ActiveRecord::Base
  DOMAIN_RNG = /\A([a-z0-9\-]+\.[a-z0-9\-]+)+\Z/

  enum kind: [
    :web_client,
    :native_client,
    :private_server
  ]

  belongs_to :user

  before_validation :generate_secret, on: :create

  after_save :store
  after_destroy :unstore

  validates :user_id, presence: true
  validates :secret,  presence: true
  validates :domain,
    allow_blank: true,
    format: { with: DOMAIN_RNG },
    if: :web_client?

  def self.lookup(raw_token)
    return unless token = Token.parse(raw_token)
    return unless token.is?(:access)
    return unless key = fetch(token[:key_id])

    SecureCompare.compare(key[:secret], token[:secret]) ? key : nil
  rescue ActiveRecord::StatementInvalid
    nil
  end

  def self.fetch(key_id)
    if (json = $redis.get(redis_key(key_id)))
      MultiJson.load(json, symbolize_keys: true)
    elsif (record = where(id: key_id).first)
      record.store
    else
      nil
    end
  end

  def self.redis_key(key_id)
    "#{Rails.env}:keys:#{key_id}"
  end

  def store
    data = {
      id:          id,
      kind:        kind,
      user_id:     user.id,
      secret:      secret,
      domain:      domain,
      is_disabled: is_disabled,
      in_devmode:  in_devmode
    }

    $redis.set(redis_key, MultiJson.dump(data))

    data
  end

  def unstore
    $redis.del(redis_key)
    true
  end

  def redis_key
    self.class.redis_key(id)
  end

  def domain=(val)
    self[:domain] = val ? val.downcase : val
  end

  def token
    @token ||= Token.new(:access, key_id: id, secret: secret)
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
