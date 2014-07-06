class API::V2::InventorySerializer < ApplicationSerializer
  DUMP_COLS = [
    :is_dead,
    :product_id,
    :store_id,
    :quantity,
    :reported_on,
    :updated_at,
  ]

  attributes *DUMP_COLS
end
