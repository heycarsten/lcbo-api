class Key < ActiveRecord::Base
  DOMAIN_RNG       = /\A([a-z0-9\-]+\.[a-z0-9\-]+)+\Z/
  MAX_PUBLIC_RATE  = 360
  MAX_PRIVATE_RATE = 3600

  belongs_to :user

  before_validation :generate_secret, on: :create

  after_save :store
  after_destroy :unstore

  validates :user_id, presence: true
  validates :secret,  presence: true
  validates :domain,
    allow_blank: true,
    format: { with: DOMAIN_RNG },
    if: :is_public?

  def self.lookup(raw_token)
    return unless token = Token.parse(raw_token)
    return unless token.is?(:access)
    return unless key = fetch(token[:key_id])

    SecureCompare.compare(key[:secret], token[:secret]) ? key : nil
  rescue ActiveRecord::StatementInvalid
    nil
  end

  def self.fetch(key_id)
    if (json = $redis.get(keyspace_for(key_id)))
      JSON.parse(json, symbolize_names: true)
    elsif (record = where(id: key_id).first)
      record.store
    else
      nil
    end
  end

  def self.keyspace_for(key_id)
    "#{Rails.env}:keys:#{key_id}"
  end

  def is_private?
    !is_public?
  end

  def store
    data = {
      id:         id,
      user_id:    user.id,
      secret:     secret,
      max_rate:   max_rate,
      is_public:  is_public,
      domain:     domain
    }

    $redis.set(keyspace, data.to_json)

    data
  end

  def unstore
    $redis.del(keyspace)
    true
  end

  def max_rate
    self[:max_rate] || begin
      is_public? ? MAX_PUBLIC_RATE : MAX_PRIVATE_RATE
    end
  end

  def keyspace
    self.class.keyspace_for(id)
  end

  def domain=(val)
    self[:domain] = val ? val.downcase : val
  end

  def token
    @token ||= Token.new(:access, key_id: id, user_id: user_id, secret: secret)
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
