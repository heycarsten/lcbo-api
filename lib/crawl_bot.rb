class CrawlBot

  include Bot::Botness

  attr_reader :crawl

  def log(message, exception = nil)
    STDOUT.puts(message)
    Rails.logger.info(message)
    @crawl.log(message)
  end

  before :all do |job_group|
    @crawl = Crawl.spawn
  end

  failure do |job, time, exception|
    log "> Job #{job} failed [#{time}]"
    @crawl.log_exception(exception)
    @crawl.fail!
  end

  after :each do |job, time|
    log "> Finished #{job} [#{time}]"
    @crawl.save
  end

  after :all do
    log "> Done [#{time}]"
    @crawl.complete!
  end

  job :get_product_lists do
    ProductsListCrawler.run(self)
  end

  job :populate_store_nos do
    @crawl.uncrawled_store_nos = (1..850).to_a
  end

  job :get_stores do
    StoresCrawler.run(self)
  end

  job :get_products do
    ProductsCrawler.run(self)
  end

  job :get_inventories do
    InventoriesCrawler.run(self)
  end

  job :post_crawl_processing do
    Crawl.perform_calculations!
  end

  job :export_sqlite do
    SQLiteExporter.run(self)
  end

  job :export_json do
    JSONExporter.run(self)
  end

  job :run_webhooks do
    Webhook.perform(self)
  end

end
