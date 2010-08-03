class DiscoveryBot

  include Bot::Crawler

  job :get_product_ids do
    ProductListsCrawler.run do |response|
      @crawl.uncrawled_product_nos << response[:product_nos]
      @crawl.save!
      dot
    end
  end

  job :hide_missing_products do
    product_nos = Products.distinct(:product_no) - @crawl.uncrawled_product_nos
    Product.where(:product_no => product_nos).update(:is_active => false)
  end

  job :crawl_new_products do
  end

end