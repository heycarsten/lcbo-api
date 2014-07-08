class APIConstraint
  def initialize(version, default = false)
    @version = version
    @default = default
    @mime    = "application/vnd.lcboapi.v#{@version}"
    @path    = "/v#{@version}"
    @verstr  = @version.to_s
  end

  def matches?(req)
    return true if @default

    if req.path.start_with?(@path)
      return true
    end

    if req.headers['Accept'].to_s.include?(@mime)
      return true
    end

    if req.headers['X-API-Version'].to_s == @verstr
      return true
    end

    false
  end
end
