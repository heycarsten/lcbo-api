class API::V2::DatasetSerializer < ApplicationSerializer
  attributes \
    :id,
    :total_products,
    :total_stores,
    :total_inventories,
    :total_product_inventory_count,
    :total_product_inventory_volume_in_milliliters,
    :total_product_inventory_price_in_cents,
    :added_product_ids,
    :added_store_ids,
    :removed_product_ids,
    :removed_store_ids,
    :created_at,
    :updated_at

  def filter(keys)
    if scope == :csv
      keys.delete_if { |k| k.to_s.end_with?('_ids') }
    end

    keys
  end
end
