class API::V2::InventorySerializer < ApplicationSerializer
  attributes \
    :id,
    :is_dead,
    :quantity,
    :reported_on,
    :updated_at

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
end
