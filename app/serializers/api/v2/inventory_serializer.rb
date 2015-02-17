class API::V2::InventorySerializer < ApplicationSerializer
  attributes \
    :type,
    :id,
    :is_dead,
    :quantity,
    :reported_on,
    :updated_at,
    :created_at

  def type
    :inventory
  end

  def id
    "#{object.product_id}-#{object.store_id}"
  end

  def attributes
    h = super

    h[:links] = {
      store:   object.store_id.to_s,
      product: object.product_id.to_s
    }

    h
  end

  def filter(keys)
    unless scope && scope[:include_dead]
      keys.delete(:is_dead)
    end

    keys
  end
end
