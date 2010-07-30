module Crawler

  # creates crawls
  # has tasks

end

Crawler::TaskSet.new do
  before :all do
  end

  after :all do
  end

  on_failure do
  end

  task :get_product_numbers do
    result = LCBO::ProductsListPageCrawler.run
    crawl.product_nos = result[:product_nos]
    crawl.save
  end

  task :get_products do
  end
end
