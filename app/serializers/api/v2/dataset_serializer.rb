class API::V2::DatasetSerializer < ApplicationSerializer
  attributes \
    :type,
    :id,
    :total_products,
    :total_stores,
    :total_inventories,
    :total_product_inventory_count,
    :total_product_inventory_volume_in_milliliters,
    :total_product_inventory_price_in_cents,
    :created_at,
    :updated_at

  def type
    :dataset
  end

  def id
    object.id.to_s
  end

  def attributes
    hsh = super

    hsh[:links] = {}.tap do |h|
      h[:products]         = (object.product_ids || []).map(&:to_s) unless scope == :index
      h[:removed_products] = (object.removed_product_ids || []).map(&:to_s)
      h[:added_products]   = (object.added_product_ids || []).map(&:to_s)
      h[:stores]           = (object.store_ids || []).map(&:to_s) unless scope == :index
      h[:removed_stores]   = (object.removed_store_ids || []).map(&:to_s)
      h[:added_stores]     = (object.added_store_ids || []).map(&:to_s)
    end

    hsh
  end

  def filter(keys)
    if scope == :csv
      keys.delete(:links)
    end

    keys
  end
end
