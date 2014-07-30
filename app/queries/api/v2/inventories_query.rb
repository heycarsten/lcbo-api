class API::V2::InventoriesQuery < Magiq::Query
  model { Inventory }

  has_pagination
end
