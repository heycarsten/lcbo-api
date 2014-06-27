require 'boticus'

class Crawler < Boticus::Bot
  UPTO_STORE_ID = 850

  def init(crawl = nil)
    @model               = (crawl || Crawl.init)
    @crawled_product_ids = []
    @crawled_inventories_ids = []
  end

  def log(level, msg, payload = {})
    super
    model.log(msg, level, payload)
  end

  def prepare
    log :info, 'Enumerating products queue'
    @product_ids = LCBO.product_ids
  end

  desc 'Crawling stores'
  task :crawl_stores do
    (1..UPTO_STORE_ID).each do |store_id|
      place_store(store_id)
    end
  end

  desc 'Crawling products'
  task :crawl_products do
    @product_ids.each do |product_id|
      place_product(product_id)
    end
  end

  desc 'Crawling inventories by store'
  task :crawl_inventories do
    model.crawled_store_ids.each do |store_id|
      place_store_inventories(store_id)
    end
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
           WHERE inventories.store_id = stores.id
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
    Product.where(id: model.removed_product_ids).update_all(is_dead: true)
  end

  desc 'Marking dead stores'
  task :mark_dead_stores do
    Store.where(id: model.removed_store_ids).update_all(is_dead: true)
  end

  desc 'Marking dead inventories'
  task :mark_dead_inventories do
    Inventory.where(product_id: model.removed_product_ids).update_all(is_dead: true)
    Inventory.where(store_id: model.removed_store_ids).update_all(is_dead: true)
  end

  desc 'Marking orphaned inventories'
  task :update_orphaned_inventories do
    Inventory.where('crawl_id != ?', model.id).update_all(quantity: 0, is_dead: true)
  end

  desc 'Exporting CSV data'
  task :export do
    Exporter.run(model.id)
  end

  desc 'Flushing page caches'
  task :flush_caches do
    LCBOAPI.flush
  end

  def place_store(id)
    log :dot, "Placing store: #{id}"

    attrs = LCBO.store(id)
    attrs[:is_dead]     = false
    attrs[:crawl_id]    = model.id
    attrs[:postal_code] = attrs[:postal_code].gsub(' ', '')

    Store.place(attrs)

    model.total_stores += 1
    model.save!
    model.crawled_store_ids << id
  rescue LCBO::NotFoundError
    log :info, "Skipping store: ##{id} (it does not exist)"
  end

  def place_product(id)
    log :dot, "Placing product: #{id}"

    attrs = LCBO.product(id)
    attrs[:crawl_id] = model.id

    Product.place(attrs)

    model.total_products += 1
    model.save!

    model.crawled_product_ids << id
  rescue LCBO::NotFoundError
    log :warn, "Skipping product: #{id} (it does not exist)"
  end

  def place_store_inventories(store_id)
    log :dot, "Placing store inventories: #{store_id}"

    inventories = LCBO.store_inventories(store_id)

    Inventory.transaction do
      inventories.each do |attrs|
        attrs[:crawl_id]   = model.id
        attrs[:is_dead]    = false
        attrs[:store_id]   = store_id
        attrs[:updated_on] = Time.now

        Inventory.place(attrs)
      end
    end

    model.total_product_inventory_count += inventories.sum { |inv| inv[:quantity] }
    model.total_inventories += inventories.size
    model.save!
  rescue LCBO::NotFoundError
    log :warn, "Skipping store inventories: #{id} (it does not exist)"
  end
end
