class API::V2::DatasetsQuery < API::V2::APIQuery
  model { Crawl }
  scope { model.is(:finished) }

  has_pagination

  equal :id, type: :id, alias: :ids, array: :allow

  sort [
    :id,
    :created_at,
    :total_products,
    :total_stores,
    :total_inventories,
    :total_product_inventory_count,
    :total_product_inventory_volume_in_milliliters,
    :total_product_inventory_price_in_cents
  ]
end
