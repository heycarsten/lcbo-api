class API::V2::StoresQuery < API::V2::APIQuery
  model { Store }

  has_pagination
  has_include_dead

  by :id, limit: 50

  unqualified [
    :distance_in_meters
  ]

  sort [
    :id,
    :distance_in_meters,
    :inventory_volume_in_milliliters,
    :products_count,
    :inventory_count,
    :inventory_price_in_cents
  ]

  toggle \
    :has_wheelchair_accessability,
    :has_bilingual_services,
    :has_product_consultant,
    :has_tasting_bar,
    :has_beer_cold_room,
    :has_special_occasion_permits,
    :has_vintages_corner,
    :has_parking,
    :has_transit_access,
    :created_at,
    :updated_at

  range :distance_in_meters,              type: :whole
  range :inventory_volume_in_milliliters, type: :whole
  range :products_count,                  type: :whole
  range :inventory_count,                 type: :whole
  range :inventory_price_in_cents,        type: :whole
  range :created_at,                      type: :date
  range :updated_at,                      type: :date

  param :product, type: :id do |id|
    scope.with_product_id(id)
  end

  param :products, type: :id, array: :always, limit: 10 do |ids|
    scope.with_product_ids(ids)
  end

  exclusive :product, :products

  def product
    @product ||= begin
      if (id = params[:product])
        Product.find(id)
      else
        nil
      end
    end
  end

  def products
    @products ||= begin
      if (ids = params[:products])
        Product.by_ids(ids)
      else
        nil
      end
    end
  end

  params :lat, :lon, type: { lat: :latitude, lon: :longitude } do |lat, lon|
    scope.distance_from(lat, lon)
  end

  param :q, type: :string do |q|
    scope.search(q)
  end

  param :geo do |geo|
    loc = GEO[geo].first.geometry.location
    scope.distance_from(loc.lat, loc.lng)
  end

  mutual [:lat, :lon], exclusive: :geo
end
