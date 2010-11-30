class Crawler

  class UnknownCrawlJobTypeError < StandardError; end

  STORE_NO_MAX = 850

  def self.run(crawl = nil)
    new(crawl).run
  end

  def self.pause(crawl = nil)
    new(crawl).pause
  end

  def initialize(crawl = nil)
    @crawl = (crawl || Crawl.init)
  end

  def start!
    log :info, 'Starting crawl!'
    @crawl.transition_to(:starting)
    log :info, 'Pushing store jobs ...'
    @crawl.push_jobs(:store, store_nos)
    log :info, 'Pushing product jobs ...'
    @crawl.push_jobs(:product, product_nos)
    @crawl.save
  end

  def pause
    log :info, 'Pausing'
    @crawl.transition_to(:paused)
  end

  def run
    begin
      if @crawl.is?(:starting) && !@crawl.has_jobs?
        start!
      else
        log :warn, 'Crawl is being resumed'
      end
      @crawl.transition_to(:running)
      work!
      diff!
      calc!
      commit!
      log :info, 'The crawl is finished.'
      @crawl.transition_to(:complete)
    rescue => error
      log_error(error)
      @crawl.transition_to(:cancelled)
    end
  end

  def work!
    return unless @crawl.is?(:running)
    log :info, 'Processing jobs...'
    while @crawl.is?(:running) && item = @crawl.jobs.pop
      begin
        runjob(item)
        @crawl.incr(:total_finished_jobs, 1)
      rescue => error
        @crawl.jobs << item
        pause
        log_error(error)
      end
    end
    log :info, 'Done processing jobs.'
  end

  def diff!
    return unless @crawl.is?(:running)
    log :info, 'Performing diff operations ...'
    log :info, 'Done performing diff operations.'
  end

  def calc!
    return unless @crawl.is?(:running)
    log :info, 'Performing calculations ...'
    log :info, 'Done performing calculations.'
  end

  def commit!
    return unless @crawl.is?(:running)
    log :info, 'Committing history ...'
    Inventory.all.each(&:commit)
    Store.all.each(&:commit)
    Product.all.each(&:commit)
    log :info, 'Done committing history.'
    log :info, 'Committing search indicies ...'
    Sunspot.commit
    log :info, 'Done comitting search indicies.'
  end

  def runjob(job)
    case job.type
    when 'product'
      run_product_job(job.no)
    when 'store'
      run_store_job(job.no)
    else
      raise UnknownCrawlJobTypeError, "Unknown type: #{job.type.inspect}"
    end
  end

  def run_product_job(product_no)
    product_attrs = LCBO.product(product_no)
    inventory_attrs = LCBO.inventory(product_no)
    inventory_attrs[:inventory_count].tap do |count|
      product_attrs.tap do |p|
        p[:is_hidden] = false
        p[:crawled_at] = Time.now.utc
        p[:inventory_count] = count
        p[:inventory_price_in_cents] = (p[:price_in_cents] * count)
        p[:inventory_volume_in_milliliters] = (p[:volume_in_milliliters] * count)
      end
    end
    Product.place(product_attrs)
    inventory_attrs[:inventories].each do |inv|
      inv[:crawled_at] = Time.now.utc
      inv[:is_hidden] = false
      inv[:product_no] = product_no
      Inventory.place(inv)
    end
    @crawl.product_nos << CrawlItem.create(:no => product_no)
    log :info, "Placed product and #{inventory_attrs[:inventories].size} inventories: #{product_no}"
  rescue LCBO::CrawlKit::Page::MissingResourceError
    log :warn, "Skipping product #{product_no}, it does not exist."
  end

  def run_store_job(store_no)
    attrs = LCBO.store(store_no)
    attrs[:crawled_at] = Time.now.utc
    attrs[:is_hidden] = false
    Store.place(attrs)
    log :info, "Placed store: #{store_no}"
    @crawl.store_nos << CrawlItem.create(:no => store_no)
  rescue LCBO::CrawlKit::Page::MissingResourceError
    log :warn, "Skipping store #{store_no}, it does not exist."
  end

  protected

  def log(level, msg, data = {})
    @crawl.log(msg, level, data)
    case level
    when :warn
      puts "[warning]".bold.yellow + " #{msg}".yellow
    when :error
      puts "[error]".bold.red + " #{msg}".red
    else
      puts "[#{level}]".bold + " #{msg}"
    end
  end

  def log_error(error, item = nil)
    h = {}
    h[:item_type] = item.type if item
    h[:item_no] = item.no if item
    h[:error_class] = error.class.to_s
    h[:error_message] = error.message
    h[:error_backtrace] = error.backtrace.join("\n")
    log(:error, "(#{error.class}) #{error.message}", h)
    puts "---\n#{h[:error_class]}\n\n#{h[:error_message]}\n#{h[:error_backtrace]}\n"
  end

  def product_nos
    @product_nos ||= begin
      LCBO.product_list(1)[:product_nos].take(20)
      # [].tap do |nos|
      #   LCBO::ProductListsCrawler.run { |page| nos.concat(page[:product_nos]) }
      # end
    end
  end

  def store_nos
    (1..STORE_NO_MAX).to_a
  end

end
