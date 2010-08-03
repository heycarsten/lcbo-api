class UpdateBot

  include Bot::Crawler

  on :after_all do
    ExportBot.r
  end

  job :get_product_lists do
    ProductsListCrawler.run do |response|
      @crawl.uncrawled_product_nos << response[:product_nos]
      @crawl.save
    end
  end

  job :populate_store_nos do
    @crawl.uncrawled_store_nos = (1..850).to_a
  end

  job :get_stores do
    #StoresCrawler.run(self)
  end

  job :get_products do
    #ProductsCrawler.run(self)
  end

  job :get_inventories do
    #InventoriesCrawler.run(self)
  end

  job :post_crawl_processing do
    #Crawl.perform_calculations!
  end

  job :export_sqlite do
    #SQLiteExporter.run(self)
  end

  job :export_json do
    #JSONExporter.run(self)
  end

  job :run_webhooks do
    #Webhook.perform(self)
  end

end
