class API::V2::ProducersQuery < API::V2::APIQuery
  model { Producer }

  has_pagination
  has_include_dead

  toggle :is_ocb

  by :id, alias: :ids, limit: 100

  sort [
    :name
  ]

  param :q, type: :string do |q|
    scope.search(q)
  end
end
