class CrawlBot

  include Bot::Crawler

  after :all do
    # Clear caches
  end

  job :seed_crawl do
    @crawl.existing_product_nos = Product.distinct(:product_no)
    @crawl.existing_store_nos   = Store.distinct(:store_no)
    @crawl.save
  end

  job :discover_stores do
    store_nos = ((1..850).to_a - @crawl.prior_store_nos)
    StoresCrawler.run(:store_no => store_nos.pop, :store_nos => store_nos) do |response|
      Store.commit(@crawl, response)
      dot
    end
  end

  job :discover_products do
    product_nos = []
    ProductListsCrawler.run do |response|
      product_nos << response[:product_nos]
      dot
    end
    product_nos = Products.distinct(:product_no) - @crawl.uncrawled_product_nos
    Product.where(:product_no.in => product_nos).update(:is_active => false)
  end

  job :update_stores do
  end

  job :update_products do
  end

  job :update_inventories do
  end

  job :perform_calculations do
  end

  job :perform_webhooks do
  end
end
