class CrawlBot

  include Bot::Crawler

  on :after_all do
    # Clear caches
  end

  job :seed_crawl do
    @crawl.existing_product_nos = Product.all.distinct(:product_no)
    @crawl.existing_store_nos   = Store.all.distinct(:store_no)
    @crawl.save
  end

  job :discover_stores do
    store_nos = ((1..850).to_a - @crawl.existing_store_nos)
    StoresCrawler.run(:store_no => store_nos.pop, :store_nos => store_nos) do |response|
      Store.commit(@crawl, response)
      dot
    end
  end

  job :discover_products do
    product_nos = []
    ProductListsCrawler.run do |response|
      product_nos.concat(response[:product_nos])
      dot
    end
    products_to_crawl = (product_nos - @crawl.existing_product_nos)
    products_to_crawl.each do |no|
      Product.create(:product_no => no, :was_crawled => false)
    end
  end

  job :update_stores do
    Store.crawlable.each do |store|
      attrs = LCBO.store(store.store_no).as_hash
      store.commit(@crawl, attrs)
      dot
    end
  end

  job :update_products do
    Product.crawlable.each do |product|
      attrs = LCBO.product(product.product_no)
      product.commit(@crawl, attrs)
      dot
    end
  end

  job :update_inventories do
    Product.inventory_crawlable.each do |product|
      attrs = LCBO.inventory(product.product_no)
      product.commit_inventory(@crawl, attrs)
      dot
    end
  end

  job :perform_calculations do
  end

  job :perform_webhooks do
  end
end
