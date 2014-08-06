class API::V2::InventoriesQuery < API::V2::APIQuery
  model { Inventory }

  has_pagination
  has_include_dead
end
