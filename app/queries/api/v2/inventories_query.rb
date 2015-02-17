class API::V2::InventoriesQuery < API::V2::APIQuery
  model { Inventory }

  has_include_dead
  has_pagination \
    max_page_size: 500,
    default_page_size: 100

  by :id, alias: :ids, type: :inventory_id, limit: 500

  sort [
    :reported_on,
    :created_at,
    :updated_at,
    :quantity
  ]

  range :reported_on, type: :date
  range :created_at,  type: :date
  range :updated_at,  type: :date
  range :quanity,     type: :whole

  param :store, alias: :stores, type: :id, array: :allow do |ids|
    scope.where(store_id: ids)
  end

  param :product, alias: :products, type: :id, array: :allow do |ids|
    scope.where(product_id: ids)
  end
end
