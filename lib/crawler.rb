require 'boticus'

class Crawler < Boticus::Bot
  def init(crawl = nil)
    @model = (crawl || Crawl.init)
  end

  def log(level, msg, payload = {})
    super
    model.log(msg, level, payload)
  end

  desc 'Getting store IDs'
  task :get_store_ids do
    @store_ids = LCBO.store_ids
  end

  desc 'Get products index via API'
  task :get_products_index_via_api do
    @api_product_ids = LCBO.products.map { |p| p[:id] }
  end

  desc 'Crawling stores'
  task :crawl_stores do
    @store_ids.each do |store_id|
      begin
        log :dot, "Placing store: #{store_id}"

        attrs            = LCBO.store(store_id)
        attrs[:is_dead]  = false
        attrs[:crawl_id] = model.id

        Store.place(attrs)

        model.total_stores += 1
        model.save!
        model.crawled_store_ids << store_id
      rescue LCBO::NotFoundError
        log :info, "Skipping store: ##{store_id} (it does not exist)"
      end
    end
    puts
  end

  desc 'Crawling products via API'
  task :crawl_api_products do
    @api_product_ids.each do |id|
      crawl_product_id(id, :api) { LCBO.product(id) }
    end

    puts
  end

  desc 'Updating product images'
  task :update_product_images do
    Product.where(is_dead: false, image_url: nil).find_each do |product|
      begin
        if (attrs = LCBO.product_images(product.id))
          product.update!(attrs)
          log :dot, "Adding image for product: #{product.id}"
        end
      rescue Excon::Error::Socket
        log :warn, "Skipping image for product: #{product.id} (Socket EOF)"
      rescue Excon::Error::Timeout
        log :warn, "Skipping image for product: #{product.id} (Timeout)"
      end
    end

    puts
  end

  desc 'Caching product images'
  task :cache_product_images do
    ImageCacher.run
  end

  desc 'Crawling inventories by product'
  task :crawl_inventories do
    model.crawled_product_ids.all.each do |product_id|
      log :dot, "Placing product inventories: #{product_id}"

      inventories = LCBO.product_inventories(product_id)

      Inventory.transaction do
        inventories.each do |attrs|
          attrs[:crawl_id]    = model.id
          attrs[:is_dead]     = false
          attrs[:product_id]  = product_id

          Inventory.place(attrs)
        end
      end

      model.total_product_inventory_count += inventories.sum { |inv| inv[:quantity] }
      model.total_inventories += inventories.size
      model.save!
    end

    puts
  end

  desc 'Checking sanity'
  task :check_sanity do
    if model.crawled_store_ids.length < 600
      raise "Dafuq! Should have crawled more than 600 stores!"
    end

    if model.crawled_product_ids.length < 8000
      raise "Dafuq! Should have crawled more than 8000 products!"
    end
  end

  desc 'Refreshing fuzzy search dictionaries'
  task :recache_fuzz do
    Fuzz.recache
  end

  desc 'Performing calculations'
  task :calculate do
    ActiveRecord::Base.connection.execute <<-SQL
      UPDATE products SET
        inventory_count = (
          SELECT SUM(inventories.quantity)
            FROM inventories
           WHERE inventories.product_id = products.id
        ),

        inventory_price_in_cents = (
          SELECT SUM(inventories.quantity * products.price_in_cents)
            FROM inventories
           WHERE inventories.product_id = products.id
        ),

        inventory_volume_in_milliliters = (
          SELECT SUM(inventories.quantity * products.volume_in_milliliters)
            FROM inventories
           WHERE inventories.product_id = products.id
        )
      ;

      UPDATE stores SET
        products_count = (
          SELECT COUNT(inventories.product_id)
            FROM inventories
           WHERE inventories.store_id = stores.id AND
                 inventories.quantity > 0
        ),

        inventory_count = (
          SELECT SUM(inventories.quantity)
            FROM inventories
           WHERE inventories.store_id = stores.id
        ),

        inventory_price_in_cents = (
          SELECT SUM(inventories.quantity * products.price_in_cents)
            FROM products
              LEFT JOIN inventories ON products.id = inventories.product_id
           WHERE inventories.store_id = stores.id
        ),

        inventory_volume_in_milliliters = (
          SELECT SUM(inventories.quantity * products.volume_in_milliliters)
            FROM products
              LEFT JOIN inventories ON products.id = inventories.product_id
           WHERE inventories.store_id = stores.id
        )
      ;
    SQL

    model.total_product_inventory_volume_in_milliliters =
      Product.where(id: model.crawled_product_ids.all).sum(:inventory_volume_in_milliliters)

    model.total_product_inventory_price_in_cents =
      Product.where(id: model.crawled_product_ids.all).sum(:inventory_price_in_cents)

    model.save!
  end

  desc 'Performing diff'
  task :diff do
    model.diff!
  end

  desc 'Marking dead products'
  task :mark_dead_products do
    Product.where.not(crawl_id: model.id).update_all(
      is_dead: true,
      inventory_count: 0,
      inventory_price_in_cents: 0,
      inventory_volume_in_milliliters: 0)
  end

  desc 'Marking dead stores'
  task :mark_dead_stores do
    Store.where.not(crawl_id: model.id).update_all(
      is_dead: true,
      products_count: 0,
      inventory_count: 0,
      inventory_price_in_cents: 0,
      inventory_volume_in_milliliters: 0
    )
  end

  desc 'Marking dead inventories'
  task :mark_dead_inventories do
    Inventory.where.not(crawl_id: model.id).update_all(
      is_dead: true,
      quantity: 0
    )
  end

  # desc 'Identifying OCB producers'
  # task :identify_ocb_producers do
  #   DataMigrator.identify_ocb_producers!
  # end

  # desc 'Identify OCB products'
  # task :identify_ocb_products do
  #   DataMigrator.identify_ocb_products!
  # end

  desc 'Marking dead producers'
  task :mark_dead_producers do
    Producer.mark_dead!
  end

  desc 'Marking dead categories'
  task :mark_dead_categories do
    Category.mark_dead!
  end

  desc 'Exporting CSV data'
  task :export do
    V1::Exporter.run(model.id)
  end

  desc 'Flushing page caches'
  task :flush_caches do
    LCBOAPI.flush
  end

  desc 'Cleanup'
  task :cleanup do
    model.rdb_flush!
    CrawlEvent.where.not(crawl_id: model.id).delete_all
  end

  def crawl_product_id(product_id, data_source)
    log :dot, "Placing product: #{product_id}"

    attrs = yield
    attrs[:crawl_id] = model.id
    attrs[:data_source] = Product.data_sources[data_source]

    Product.place(attrs)

    model.total_products += 1
    model.save!

    model.crawled_product_ids << product_id
  rescue LCBO::NotFoundError
    log :warn, "Skipping product: #{product_id} (it does not exist)"
  end
end
