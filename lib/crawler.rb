class Crawler

  class UnknownCrawlJobTypeError < StandardError; end

  STORE_NO_MAX = 900

  def self.run(crawl = nil)
    new(crawl).run
  end

  def initialize(crawl = nil)
    @crawl = (crawl || Crawl.init)
  end

  def start
    @crawl.transition_to(:starting)
    @crawl.push_jobs(:store, store_nos)
    @crawl.push_jobs(:product, product_nos)
    @crawl.product_nos = product_nos
    @crawl.save
  end

  def run
    start if @crawl.is?(:starting) && !@crawl.has_jobs?
    @crawl.transition_to(:running)

    @crawl.popjob do |job|
      case job.type
      when 'product'
        update_product(job.no)
      when 'store'
        update_store(job.no)
      else
        raise UnknownCrawlJobTypeError, "Unknown type: #{job.type.inspect}"
      end
    end

    perform_calculations

    Inventory.each(&:commit)
    Store.each(&:commit)
    Product.each(&:commit)

    @crawl.transition_to(:complete)
  end

  def update_store(store_no)
    
  end

  def update_product(product_no)
    
  end

  def update_product_inventory(product_no)
    
  end

  protected

  def product_nos
    @product_nos ||= begin
      [].tap do |nos|
        LCBO::ProductListsCrawler.run { |page| nos.concat(page[:product_nos]) }
      end
    end
  end

  def store_nos
    (1..STORE_NO_MAX).to_a
  end

end
