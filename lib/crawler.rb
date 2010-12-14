class Crawler < Boticus::Bot

  class UnknownJobTypeError < StandardError; end

  class ProductListsGetter
    include LCBO::CrawlKit::Crawler

    def request(params)
      LCBO.product_list(params[:next_page] || 1)
    end

    def continue?(current_params)
      current_params[:next_page] ? true : false
    end

    def reduce
      responses.map { |params| params[:product_nos] }.flatten
    end
  end

  def init(crawl = nil)
    @model = (crawl || Crawl.init)
  end

  def log(level, msg, payload = {})
    super
    model.log(msg, level, payload)
  end

  def prepare
    log :info, 'Enumerating product job queue ...'
    model.push_jobs(:product, ProductListsGetter.run)
    log :info, 'Enumerating store job queue ...'
    model.push_jobs(:store, LCBO.store_list[:store_nos])
  end

  desc 'Crawling stores, products, and inventories'
  task :crawl do
    while (model.is?(:running) && pair = model.popjob)
      case pair[0]
        when 'product' then place_product_and_inventories(pair[1])
        when 'store'   then place_store(pair[1])
      end
      model.total_finished_jobs += 1
      model.save
    end
    puts
  end

  desc 'Performing calculations'
  task :calculate do
    DB[
      <<-SQL
      UPDATE stores
        SET
          products_count  = (SELECT COUNT(inventories.product_id) FROM inventories WHERE inventories.store_id = stores.id),
          inventory_count = (SELECT SUM(inventories.quantity)     FROM inventories WHERE inventories.store_id = stores.id),
          inventory_price_in_cents = (SELECT SUM(inventories.quantity * products.price_in_cents) FROM products LEFT JOIN inventories ON products.id = inventories.product_id WHERE inventories.store_id = stores.id)
          inventory_volume_in_milliliters = (SELECT SUM(inventories.quantity * products.volume_in_milliliters) FROM products LEFT JOIN inventories ON products.id = inventories.product_id WHERE inventories.store_id = stores.id)
        WHERE
          EXISTS (SELECT * FROM inventories WHERE inventories.store_id = stores.id)
      SQL
    ]
  end

  desc 'Committing stores'
  task :commit_stores do
    log :info, "Committing history for #{Store.count} stores ..."
    Store.each do |store|
      log :dot, "Committing store ##{store.id}"
      store.commit
    end
    puts
  end

  desc 'Committing products'
  task :commit_products do
    DB[
      <<-SQL
      INSERT INTO product_revisions
        SELECT #{}
      SQL
    ]
    log :info, "Committing history for #{Product.count} products ..."
    count = 0
    Product.each_page(500) do |page|
      page.select(:id).each do |row|
        Product[row[:id]].commit
        count += 1
      end
      log :dot, "Committed a batch of products (Total: #{count})"
    end
    puts
  end

  desc 'Committing inventories'
  task :commit_inventories do
    DB[<<-SQL
      INSERT INTO inventory_revisions
        SELECT #{DB[:inventory_revisions].columns.join(', ')}
        FROM inventories
    SQL
    ]
  end

  def place_store(store_no)
    attrs = LCBO.store(store_no)
    attrs[:is_dead] = false
    attrs[:crawl_id] = model.id
    Store.place(attrs)
    log :dot, "Placed store: #{store_no}"
    model.total_stores += 1
    model.save
    model.store_nos << store_no
    log :dot, "Placed store ##{store_no}"
  rescue LCBO::CrawlKit::NotFoundError
    log :warn, "Skipping store ##{store_no}, it does not exist."
  end

  def place_product_and_inventories(product_no)
    pattrs = LCBO.product(product_no)
    iattrs = LCBO.inventory(product_no)
    iattrs[:inventory_count].tap do |count|
      pattrs.tap do |p|
        p[:crawl_id] = model.id
        p[:is_dead] = false
        p[:inventory_count] = count
        p[:inventory_price_in_cents] = (p[:price_in_cents] * count)
        p[:inventory_volume_in_milliliters] = (p[:volume_in_milliliters] * count)
      end
    end
    Product.place(pattrs)
    iattrs[:inventories].each do |inv|
      inv[:crawl_id] = model.id
      inv[:is_dead] = false
      inv[:product_no] = product_no
      Inventory.place(inv)
    end
    model.total_products += 1
    model.total_inventories += iattrs[:inventories].size
    model.total_product_inventory_count += iattrs[:inventory_count]
    model.total_product_inventory_price_in_cents += pattrs[:inventory_price_in_cents]
    model.total_product_inventory_volume_in_milliliters += pattrs[:inventory_volume_in_milliliters]
    model.save
    model.product_nos << product_no
    log :dot, "Placed product ##{product_no} and #{iattrs[:inventories].size} inventories"
  rescue LCBO::CrawlKit::NotFoundError
    log :warn, "Skipping product ##{product_no}, it does not exist."
  end

end
