class API::V2::StoresController < API::V2::APIController
  def index
    data        = {}
    linked      = []
    query       = API::V2::StoresQuery.new(params)
    scope       = query.to_scope
    results     = scope.load
    product     = query.product
    products    = query.products
    inventories = extract_inventories(results)

    data[:data] = results.map { |s| serialize_store(s, params) }

    if product
      linked << serialize_product(product)
    end

    if products
      products.each { |p| linked << serialize_product(p) }
    end

    if inventories
      inventories.each { |i| linked << i }
    end

    unless linked.empty?
      data[:linked] = linked
    end

    if (pagination = pagination_for(scope))
      data[:meta] = pagination
    end

    render_json(data)
  end

  def show
    data  = {}
    store = Store.find(params[:id])

    data[:data] = serialize_store(store, include_dead: true)

    render_json(data)
  end

  private

  def serialize_store(store, scope = nil)
    API::V2::StoreSerializer.new(store,
      scope: scope || params
    ).as_json(root: false)
  end

  def serialize_product(product)
    API::V2::ProductSerializer.new(product).as_json(root: false)
  end

  def extract_inventories(stores)
    extract_product_inventories(stores) || extract_products_inventories(stores)
  end

  def extract_product_inventories(stores)
    return unless params.key?(:product)

    stores.reduce([]) { |ary, store|
      next ary unless (product_id = store.try(:inventory_product_id))

      ary << {
        type: :inventory,
        id: "#{product_id}-#{store.id}",
        links: {
          product:  product_id.to_s,
          store:    store.id.to_s
        },
        quantity:    store.inventory_quantity,
        reported_on: store.inventory_reported_on,
        updated_at:  store.inventory_updated_at
      }
    }
  end

  def extract_products_inventories(stores)
    return unless params.key?(:product)

    stores.reduce([]) { |ary, store|
      next ary unless (product_ids = store.try(:inventory_product_ids))

      dates      = store.inventories_reported_on
      quantities = store.inventory_quantities
      times      = store.inventories_updated_at

      product_ids.each_with_index do |product_id, i|
        ary << {
          type: :inventory,
          id: "#{product_id}-#{store.id}",
          links: {
            product: product_id.to_s,
            store:   store.id.to_s,
          },
          quantity:    quantities[i],
          reported_on: dates[i],
          updated_at:  times[i]
        }
      end

      ary
    }
  end
end
