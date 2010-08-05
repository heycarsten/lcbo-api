class StoresCrawler

  MAX_STORE_NO = 850
  MAX_RETRIES = 10

  class Error < StandardError; end
  class EpicTimeoutError < Error; end

  def self.run(params, tries = 0, &block)
    begin
      payload = LCBO.store(params[:store_no]).as_hash
      yield payload
      params[:store_no] = params[:store_nos].pop
      run(params, &block)
    rescue Errno::ETIMEDOUT, Timeout::Error
      raise EpicTimeoutError if tries > MAX_RETRIES
      run(parmas, (tries + 1), &block)
    rescue LCBO::StorePage::MissingResourceError
      params[:store_no] = params[:store_nos].pop
      run(params, &block)
    end
  end

end
