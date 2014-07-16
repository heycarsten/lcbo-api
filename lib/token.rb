class Token
  class Error < StandardError; end
  class InvalidError < Error; end

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

    key = if opts[:id]
      Base62.uuid_encode(opts[:id])
    elsif opts[:key]
      opts[:key]
    else
      random(opts[:key_size] || KEY_SIZE)
    end

    secret = opts[:secret] || random(opts[:secret_size] || SECRET_SIZE)

    new(key, secret, kind)
  end

  def self.random(size)
    SecureRandom.urlsafe_base64(size)[0, size].tr('_-', 'aA')
  end

  def self.parse!(raw_payload)
    payload = raw_payload.to_s.strip

    raise InvalidError, "payload is empty" if payload.blank?
    raise InvalidError, "payload has no delimiter" unless payload.include?(DELIMITER)

    key    = nil
    secret = nil
    kind   = nil

    KINDS.each_pair do |k, tag|
      next unless payload.start_with?(tag)
      key, secret = *payload.sub(tag, '').split(DELIMITER)
      kind = k
      break
    end

    if kind
      new(key, secret, kind)
    else
      raise InvalidError, "payload is an unknown type"
    end
  end

  def self.parse(payload)
    parse!(payload)
  rescue InvalidError
    nil
  end

  def initialize(key, secret, kind)
    unless KINDS.keys.include?(kind)
      raise ArgumentError, "Unknown token kind: #{kind.inspect}"
    end

    @key, @secret, @kind = key, secret, kind
  end

  def id
    @id ||= Base62.uuid_decode(@key)
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

  def to_param
    to_s
  end
end
