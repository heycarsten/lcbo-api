class Key < ApplicationRecord
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
    presence: true,
    format: { with: DOMAIN_RNG },
    if: ->(key) { key.web_client? }

  validates :label, presence: true

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

  def self.redis_total_requests_key(key_id)
    "#{redis_key(key_id)}:total_requests"
  end

  def self.redis_cycle_total_requests_key(key_id, cycle)
    "#{redis_key(key_id)}:cycles:#{cycle}:total_requests"
  end

  def self.redis_cycle_daily_request_totals_key(key_id, cycle)
    "#{redis_key(key_id)}:cycles:#{cycle}:daily_request_totals"
  end

  def self.redis_cycles_key(key_id)
    "#{redis_key(key_id)}:cycles"
  end

  def self.redis_ip_requests_per_hour_key(key_id, ip)
    "#{redis_key(key_id)}:ips:#{ip}:requests_per_hour"
  end

  def self.redis_hourly_ips_log_key(key_id)
    "#{redis_key(key_id)}:hourly_ips_log"
  end

  def total_requests
    $redis.get(Key.redis_total_requests_key(id)).to_i
  end

  def cycle_requests
    now    = Time.now
    first  = now.beginning_of_month.to_date
    last   = now.end_of_month.to_date
    rkey   = Key.redis_cycle_daily_request_totals_key(id, first.strftime('%Y-%m'))
    scores = Hash[$redis.zrange(rkey, 0, -1, withscores: true)]
    ret    = []

    first.upto(last) do |date|
      isodate = date.to_s
      ret << [isodate, (scores[isodate] || 0).to_i]
    end

    ret
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
