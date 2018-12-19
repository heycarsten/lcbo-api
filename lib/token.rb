class Token
  class Error < StandardError; end
  class InvalidError < Error; end

  attr_reader :kind, :index, :values, :params

  SECRET_SIZE = 36
  DELIMITER   = ':'

  SIGNATURES = {
    access:       [:key_id,   :secret],
    session:      [:user_id,  :secret],
    auth:         [:user_id,  :secret],
    verification: [:user_id,  :secret],
    email:        [:email_id, :secret]
  }

  def self.lookup_index(kind_index)
    lookup(SIGNATURES.keys[kind_index])
  end

  def self.lookup(kind)
    if (found = SIGNATURES[kind])
      found
    else
      raise ArgumentError, "unknown kind: #{kind.inspect}"
    end
  end

  def self.random(size)
    SecureRandom.urlsafe_base64(size)[0, size].tr('_-', 'aA')
  end

  def self.generate_secret
    random(SECRET_SIZE)
  end

  def self.generate(kind, params = {})
    params[:secret] ||= generate_secret
    new(kind, params)
  end

  def self.parse!(raw_payload)
    payload = raw_payload.to_s.strip

    raise InvalidError, "payload is empty" if payload.blank?

    begin
      decoded = Base64.urlsafe_decode64(payload)
    rescue ArgumentError
      raise InvalidError, "payload is not valid base64"
    end

    raise InvalidError, "payload has no delimiter" unless decoded.include?(DELIMITER)

    parts     = decoded.split(DELIMITER)
    index     = parts[0].to_i
    signature = lookup_index(index)
    kind      = SIGNATURES.keys[index]

    params = {}

    signature.each_with_index do |part, i|
      if (val = parts[i + 1])
        params[part] = val
      else
        raise InvalidError, "payload is missing value at :#{part}"
      end
    end

    new(kind, params)
  end

  def self.parse(raw_payload)
    parse!(raw_payload)
  rescue InvalidError
    nil
  end

  def initialize(kind_or_index, params = {})
    if kind_or_index.is_a?(Integer)
      @signature = self.class.lookup_index(kind_or_index)
      @index     = kind_or_index
    else
      @signature = self.class.lookup(kind_or_index)
      @index     = SIGNATURES.keys.index(kind_or_index)
    end

    @kind   = SIGNATURES.keys[@index]
    @params = params
    @values = []

    @signature.each do |key|
      if (val = params[key])
        @values << val
      else
        raise InvalidError, "token params must include :#{key}"
      end
    end
  end

  def is?(kind)
    self.class.lookup(kind)
    @kind == kind
  end

  def [](key)
    @params[key]
  end

  def payload
    @payload ||= [@index].concat(@values).join(DELIMITER)
  end

  def to_s
    @to_s ||= Base64.urlsafe_encode64(payload)
  end

  def to_param
    to_s
  end
end
