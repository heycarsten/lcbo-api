class SeedJob < Bot::Job

  def initialize
    @crawl = Crawl.fetch
  end

  def self.perform
    crawler = new
    crawler.perform
    crawler
  end

  def perform
    product_nos
    store_nos
    self
  end

  def store_nos
    @store_nos ||= (1..900).to_a
  end

  def product_nos
    @product_nos ||= (new_product_nos | existing_product_nos)
  end

  protected

  def existing_product_nos
    @existing_product_nos ||= Product.all.map(&:product_no)
  end

  def new_product_nos
    @new_product_nos ||= begin
      product_nos = []
      LCBO::ProductListsCrawler.run(:page => 1) do |params|
        product_nos.concat(params[:product_nos])
      end
      product_nos
    end
  end

end
