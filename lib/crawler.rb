class ProductListsCrawler < Crawler
  def request(params = {})
    LCBO.product_list(params[:next_page] || 1)
  end

  def continue?(response)
    response[:next_page] ? true : false
  end
end

class Crawler

  class UnknownCrawlJobTypeError < StandardError; end
  class EpicTimeoutError < StandardError; end

  class ProductListsCrawler
    MAX_RETRIES = 10

    def self.run(params = {}, tries = 0, &block)
      raise ArgumentError, 'block expected' unless block_given?
      begin
        payload = LCBO.product_list(params[:page] || 1)
        yield(payload)
        run(:page => payload[:next_page], &block) if payload[:next_page]
      rescue Errno::ETIMEDOUT, Timeout::Error
        # On timeout, try again.
        raise EpicTimeoutError if tries > MAX_RETRIES
        run(params, (tries + 1), &block)
      end
    end
  end

  def self.run(crawl = nil)
    new(crawl).run
  end

  def self.pause(crawl = nil)
    new(crawl).pause
  end

  def initialize(crawl = nil)
    @crawl = (crawl || Crawl.init)
  end

  def init(crawl = nil)
    @crawl = (crawl || Crawl.init)
  end

  event :startup do
    if @crawl.is?(:starting) && !@crawl.has_jobs?
      log :info, 'Starting crawl'
      @crawl.transition_to(:starting)
      log :info, 'Pushing product jobs ...'
      @crawl.push_jobs(:product, product_nos)
      log :info, 'Pushing store jobs ...'
      @crawl.push_jobs(:store, store_nos)
    else
      log :warn, 'Crawl is being resumed'
    end
  end

  event :work, :transition_to => :running do
    
  end

  def run
    
  end

  def pause
    log :info, 'Pausing'
    @crawl.transition_to(:paused)
  end

  def run
    begin
      @crawl.transition_to(:running)
      crawl!
      perform_store_calculations!
      diff!
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
    while @crawl.is?(:running) && pair = @crawl.popjob
      begin
        runjob(*pair)
        @crawl.total_finished_jobs += 1
        @crawl.save
      rescue => error
        @crawl.addjob(*pair)
        log_error(error)
        raise error
      end
    end
    log :info, 'Done processing jobs.'
  end

  def diff!
    return unless @crawl.is?(:running)
    log :info, 'Performing diff operations ...'
    log :info, 'Done performing diff operations.'
  end

  def perform_store_calculations!
    log :info, 'Calculating total store inventory values ...'
    DB[
      <<-SQL
      UPDATE stores
        SET
          products_count  = (SELECT COUNT(inventories.product_id) FROM inventories WHERE inventories.store_id = stores.id),
          inventory_count = (SELECT SUM(inventories.quantity)     FROM inventories WHERE inventories.store_id = stores.id),
          inventory_price_in_cents = (SELECT SUM(inventories.quantity * products.price_in_cents) FROM products LEFT JOIN inventories ON products.id = inventories.product_id WHERE inventories.store_id = stores.id)
          inventory_volume_in_milliliters = (SELECT SUM(inventories.quantity * products.volume_in_milliliters) FROM products LEFT JOIN inventories ON products.id = inventories.product_id WHERE inventories.store_id = stores.id)
        WHERE
          EXISTS (SELECT * FROM inventories WHERE inventories.store_id = stores.id)
      SQL
    ]
  end

  def commit!
    return unless @crawl.is?(:running)
    log :info, 'Committing history ...'
    Store.each_page(100, &:commit)
    Product.each_page(500, &:commit)
    Inventory.each_page(1000, &:commit)
    log :info, 'Done committing history.'
  end

  def runjob(type, id)
    case type
    when 'product'
      run_product_job(id)
    when 'store'
      run_store_job(id)
    else
      raise UnknownCrawlJobTypeError, "Unknown type: #{type.inspect}"
    end
  end

  def run_product_job(product_no)
    pattrs = LCBO.product(product_no)
    iattrs = LCBO.inventory(product_no)
    iattrs[:inventory_count].tap do |count|
      pattrs.tap do |p|
        p[:crawl_id] = @crawl.id
        p[:is_hidden] = false
        p[:inventory_count] = count
        p[:inventory_price_in_cents] = (p[:price_in_cents] * count)
        p[:inventory_volume_in_milliliters] = (p[:volume_in_milliliters] * count)
      end
    end
    Product.place(pattrs)
    iattrs[:inventories].each do |inv|
      inv[:crawl_id] = @crawl.id
      inv[:is_hidden] = false
      inv[:product_no] = product_no
      Inventory.place(inv)
    end
    update_product_inventory_counters(pattrs, iattrs)
    @crawl.product_nos << product_no
    log :info, "Placed product and #{iattrs[:inventories].size} inventories: #{product_no}"
  rescue LCBO::CrawlKit::Page::MissingResourceError
    log :warn, "Skipping product #{product_no}, it does not exist."
  end

  def update_product_inventory_counters(product, inv)
    @crawl.total_products += 1
    @crawl.total_inventories += inv[:inventories].size
    @crawl.total_product_inventory_count += inv[:inventory_count]
    @crawl.total_product_inventory_price_in_cents += product[:inventory_price_in_cents]
    @crawl.total_product_inventory_volume_in_milliliters += product[:inventory_volume_in_milliliters]
    @crawl.save
  end

  def run_store_job(store_no)
    attrs = LCBO.store(store_no)
    attrs[:is_hidden] = false
    attrs[:crawl_id] = @crawl.id
    Store.place(attrs)
    log :info, "Placed store: #{store_no}"
    @crawl.total_stores += 1
    @crawl.save
    @crawl.store_nos << store_no
  rescue LCBO::CrawlKit::Page::MissingResourceError
    log :warn, "Skipping store #{store_no}, it does not exist."
  end

  protected

  def log(level, msg, data = {})
    @crawl.log(msg, level, data)
    case level
    when :warn
      print "[warning]".bold.yellow
      print " #{msg}\n".yellow
    when :error
      print "[error]".bold.red
      print " #{msg}\n".red
    else
      print "[#{level}]".bold
      print " #{msg}\n"
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
      [].tap do |nos|
        ProductListsCrawler.run { |page| nos.concat(page[:product_nos]) }
      end
    end
  end

  def store_nos
    @store_nos ||= LCBO.store_list[:store_nos]
  end

end
