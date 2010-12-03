class Crawler

  class UnknownCrawlJobTypeError < StandardError; end

  STORE_NO_MAX = 900

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
    log :info, 'Starting crawl'
    @crawl.transition_to(:starting)
    log :info, 'Pushing product jobs ...'
    @crawl.push_jobs(:product, product_nos)
    log :info, 'Pushing store jobs ...'
    @crawl.push_jobs(:store, store_nos)
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
    while @crawl.is?(:running) && pair = @crawl.popjob
      begin
        runjob(*pair)
        @crawl.increment(:total_finished_jobs)
      rescue => error
        @crawl.addjob(*pair)
        log_error(error)
        pause
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
    log :info, 'Calculating total store inventory values ...'
    Store.find_each do |store|
      h = {}
      h[:products_count] = 0
      h[:inventory_count] = 0
      h[:inventory_price_in_cents] = 0
      h[:inventory_volume_in_milliliters] = 0
      Inventory.where(:store_id => store).all(:include => [:product]).each do |inv|
        h[:products_count] += 1
        h[:inventory_count] += inv.quantity
        h[:inventory_price_in_cents] += (inv.quantity * inv.product.price_in_cents)
        h[:inventory_volume_in_milliliters] += (inv.quantity * inv.product.volume_in_milliliters)
      end
      store.update_attributes(h)
      log :info, "Performed calculations for store: #{store.id}"
    end
    log :info, 'Done performing calculations.'
  end

  def commit!
    return unless @crawl.is?(:running)
    log :info, 'Committing history ...'
    Inventory.all.each(&:commit)
    Store.all.each(&:commit)
    Product.all.each(&:commit)
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
    product_attrs = LCBO.product(product_no)
    inventory_attrs = LCBO.inventory(product_no)
    inventory_attrs[:inventory_count].tap do |count|
      product_attrs.tap do |p|
        p[:crawl_id] = @crawl.id
        p[:is_hidden] = false
        p[:inventory_count] = count
        p[:inventory_price_in_cents] = (p[:price_in_cents] * count)
        p[:inventory_volume_in_milliliters] = (p[:volume_in_milliliters] * count)
      end
    end
    Product.place(product_attrs)
    inventory_attrs[:inventories].each do |inv|
      inv[:crawl_id] = @crawl.id
      inv[:is_hidden] = false
      inv[:product_no] = product_no
      Inventory.place(inv)
    end
    update_product_inventory_counters(product_attrs, inventory_attrs)
    @crawl.product_nos << product_no
    log :info, "Placed product and #{inventory_attrs[:inventories].size} inventories: #{product_no}"
  rescue LCBO::CrawlKit::Page::MissingResourceError
    log :warn, "Skipping product #{product_no}, it does not exist."
  end

  def update_product_inventory_counters(product, inv)
    @crawl.increment(:total_products)
    @crawl.increment(:total_inventories, inv[:inventories].size)
    @crawl.increment(:total_product_inventory_count, inv[:inventory_count])
    @crawl.increment(:total_product_inventory_price_in_cents, product[:inventory_price_in_cents])
    @crawl.increment(:total_product_inventory_volume_in_milliliters, product[:inventory_volume_in_milliliters])
  end

  def run_store_job(store_no)
    attrs = LCBO.store(store_no)
    attrs[:is_hidden] = false
    attrs[:crawl_id] = @crawl.id
    Store.place(attrs)
    log :info, "Placed store: #{store_no}"
    @crawl.increment(:total_stores)
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
      LCBO.product_list(1)[:product_nos].take(10)
      # [].tap do |nos|
      #   LCBO::ProductListsCrawler.run { |page| nos.concat(page[:product_nos]) }
      # end
    end
  end

  def store_nos
    (1..STORE_NO_MAX).to_a
  end

end
