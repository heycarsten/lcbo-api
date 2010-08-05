class ParseCrawlResponseJob

  DOCS = {
    LCBO::InventoryPage => Inventory,
    LCBO::ProductPage   => Product,
    LCBO::StorePage     => Store }

  @queue = :responses

  def self.perform(type, crawl_timestamp, response)
    crawl = Crawl.where(:timestamp => crawl_timestamp)
    page  = LCBO.parse(type, response)
    doc   = DOCS[page.class]
    doc.commit(crawl, page.as_hash)
  end

end
