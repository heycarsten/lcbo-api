module Base62
  CHARS = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.chars
  BASE  = CHARS.size

  module_function

  def encode(int)
    out = ''

    while int >= BASE
      mod = int % BASE
      out = CHARS[mod] + out
      int = (int - mod) / BASE
    end

    CHARS[int] + out
  end

  def decode(b62)
    int = 0
    rev = b62.reverse.chars

    rev.each_with_index do |char, i|
      int += CHARS.index(char) * (BASE ** i)
    end

    int
  end

  def uuid_encode(uuid)
    encode(Integer("0x#{uuid.gsub('-', '')}"))
  end

  def uuid_decode(b62)
    sprintf('%032x', decode(b62))
  end
end
