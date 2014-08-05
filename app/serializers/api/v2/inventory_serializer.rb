class API::V2::InventorySerializer < ApplicationSerializer
  attributes \
    :id,
    :is_dead,
    :product_id,
    :store_id,
    :quantity,
    :reported_on,
    :updated_at

  def id
    "#{object.product_id}-#{object.store_id}"
  end
end
