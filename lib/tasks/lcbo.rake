namespace :lcbo do
  namespace :request do
    desc 'Request and normalize a given product'
    task :product, [:product_no] => :environment do |t, args|
      pp LCBO.product(args.product_no)
    end

    desc 'Request and normalize a given store'
    task :store, [:store_no] => :environment do |t, args|
      pp LCBO.store(args.store_no)
    end

    desc 'Request and normalize a given product inventory'
    task :inventory, [:product_no] => :environment do |t, args|
      pp LCBO.inventory(args.product_no)
    end

    desc 'Request and normalize a given products list page'
    task :products_list, [:page] => :environment do |t, args|
      pp LCBO.products_list(args.page)
    end
  end

  namespace :crawl do
    desc 'Begin a crawl of everything'
    task :all do
    end

    desc 'Begin a crawl of all stores'
    task :stores do
    end

    desc 'Begin a crawl of all products'
    task :products do
    end

    desc 'Begin a crawl of all inventories'
    task :inventories do
    end
  end
end
