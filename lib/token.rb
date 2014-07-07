class Token
  attr_reader :key, :secret, :kind

  KEY_SIZE    = 12
  SECRET_SIZE = 36
  DELIMITER   = '-'

  KINDS = {
    api:          'k_',
    session:      's_',
    auth:         'a_',
    verification: 'v_'
  }

  def self.generate(kind, opts = {})
    unless KINDS.keys.include?(kind)
      raise ArgumentError, "Unknown kind: #{kind.inspect}"
    end

    key    = opts[:key]    || random(opts[:key_size] || KEY_SIZE)
    secret = opts[:secret] || random(opts[:secret_size] || SECRET_SIZE)

    new(key, secret, kind)
  end

  def self.random(size)
    SecureRandom.urlsafe_base64(size)[0, size].tr('_-', 'aA')
  end

  def self.parse(payload)
    raise InvalidError if payload.blank?
    raise InvalidError unless payload.include?(DELIMITER)

    key    = nil
    secret = nil
    kind   = nil

    KINDS.each_pair do |kind, tag|
      next unless payload.start_with?(tag)
      key, secret = *payload.sub(tag, '').split(DELIMITER)
      kind = kind
      break
    end

    if kind
      new(key, secret, kind)
    else
      nil
    end
  end

  def initialize(key, secret, kind)
    unless KINDS.keys.include?(kind)
      raise ArgumentError, "Unknown token kind: #{kind.inspect}"
    end

    @key, @secret, @kind = key, secret, kind
  end

  def api?
    kind == :api
  end

  def session?
    kind == :session
  end

  def auth?
    kind == :auth
  end

  def verification?
    kind == :verification
  end

  def to_s
    KINDS[kind] + key + DELIMITER + secret
  end
end
