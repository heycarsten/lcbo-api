class API::V2::StoresController < API::V2::APIController
  def index
    data        = {}
    query       = API::V2::StoresQuery.new(params)
    scope       = query.to_scope
    results     = scope.load
    product     = query.product
    products    = query.products
    inventories = extract_inventories(results)

    data[:stores] = results.map { |r| serializer.new(r).as_json(root: false) }

    if product
      data[:product] = serialize_product(product)
    end

    if products
      data[:products] = products.map { |p| serialize_product(p) }
    end

    if inventories
      data[:inventories] = inventories
    end

    if (pagination = pagination_for(scope))
      data[:meta] = pagination
    end

    render json: data, callback: params[:callback]
  end

  def show
    respond_with :api, :v2, Store.find(params[:id]),
      serializer: serializer,
      callback:   params[:callback]
  end

  private

  def extract_inventories(stores)
    extract_product_inventories(stores) || extract_products_inventories(stores)
  end

  def extract_product_inventories(stores)
    return unless params.key?(:product_id)

    stores.reduce([]) { |ary, store|
      next ary unless (product_id = store.try(:inventory_product_id))

      ary << {
        id:          "#{product_id}-#{store.id}",
        is_dead:     false,
        product_id:  product_id,
        store_id:    store.id,
        quantity:    store.inventory_quantity,
        reported_on: store.inventory_reported_on,
        updated_at:  store.inventory_updated_at
      }
    }
  end

  def extract_products_inventories(stores)
    return unless params.key?(:product_ids)

    stores.reduce([]) { |ary, store|
      next ary unless (product_ids = store.try(:inventory_product_ids))

      dates      = store.inventories_reported_on
      quantities = store.inventory_quantities
      times      = store.inventories_updated_at

      product_ids.each_with_index do |product_id, i|
        ary << {
          id:          "#{product_id}-#{store.id}",
          is_dead:     false,
          product_id:  product_id,
          store_id:    store.id,
          quantity:    quantities[i],
          reported_on: dates[i],
          updated_at:  times[i]
        }
      end

      ary
    }
  end

  def serialize_product(product, opts = {})
    API::V2::ProductSerializer.new(product, opts).as_json(root: false)
  end
end
