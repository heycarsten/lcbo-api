class SeedJob < Bot::Job

  attr_reader :product_nos, :store_nos

  def initialize
    @product_nos = []
    @store_nos = []
  end

  def self.perform
    crawler = new
    crawler.get_product_nos
    crawler.get_store_nos
    crawler
  end

  def update
    get_product_nos
    get_store_nos
  end

  protected

  def existing_product_nos
  end

  def existing_store_nos
    
  end

  def get_product_nos
    LCBO::ProductListsCrawler.run(:page => 1) do |params|
      @product_nos.concat(params[:product_nos])
    end
    @product_nos
  end

  def get_store_nos
    @store_nos = (1..850).to_a
  end

end
