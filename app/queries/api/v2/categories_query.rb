class API::V2::CategoriesQuery < API::V2::APIQuery
  model { Category }

  has_include_dead

  by :depth, type: :category_depth, limit: 3
  by :id, limit: 100

  sort [
    :name,
    :depth,
    :created_at,
    :updated_at
  ]

  param :q, type: :string do |q|
    scope.search(q)
  end

  param :parent_category, type: :id do |id|
    scope.where(parent_category_id: id)
  end
end
