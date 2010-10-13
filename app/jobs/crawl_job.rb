class CrawlJob < Bot::Job

  class AlreadyCrawlingError < StandardError; end

  def perform
    raise AlreadyCrawlingError if Crawl.any_active?
    store_nos = (1..850).to_a
    product_nos = begin
      nos = get_product_nos
      nos = Product.all.map(&:product_no)

    @crawl = Crawl.init
    @crawl.store_nos = store_nos
    @crawl.product_nos = product_nos

    @crawl.set_state(:running)

    @crawl.popjob do |type, no|
      case type
      when 'store'
        LCBO::StorePage.
      when 'product'
      end
    end
  end

  def get_product_nos
    @get_product_nos ||= begin
      nos = []
      LCBO::ProductListsCrawler.run(:page => 1) do |params|
        nos.concat(params[:product_nos])
      end
      nos
    end
  end

end
