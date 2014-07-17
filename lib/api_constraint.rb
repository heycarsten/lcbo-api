class APIConstraint
  def initialize(version, default = false)
    @version = version
    @default = default
    @path    = "/v#{@version}"
    @verstr  = @version.to_s
    @mimes   = case @version
    when 1
      ['application/json', 'application/vnd.lcboapi.v1+json']
    when 2
      ['application/vnd.api+json', 'application/vnd.lcboapi.v2+json']
    else
      raise ArgumentError, "unknown API version: #{@version.inspect}"
    end
  end

  def matches?(req)
    return true if @default

    if req.path.start_with?(@path)
      return true
    end

    if @mimes.any? { |m| req.headers['Accept'].to_s.include?(m) }
      return true
    end

    if req.headers['X-API-Version'].to_s == @verstr
      return true
    end

    false
  end
end
