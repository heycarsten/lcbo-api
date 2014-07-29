class API::V2::StoresQuery < Magiq::Query
  model { Store }

  has_pagination

  param :include_dead, type: :bool
  apply do
    scope.where(is_dead: false) unless params[:include_dead]
  end

  equal :id, array: true

  order \
    :id,
    :distance_in_meters,
    :inventory_volume_in_milliliters,
    :products_count,
    :inventory_count,
    :inventory_price_in_cents

  bool \
    :has_wheelchair_accessability,
    :has_bilingual_services,
    :has_product_consultant,
    :has_tasting_bar,
    :has_beer_cold_room,
    :has_special_occasion_permits,
    :has_vintages_corner,
    :has_parking,
    :has_transit_access

  range :distance_in_meters,              type: :whole
  range :inventory_volume_in_milliliters, type: :whole
  range :products_count,                  type: :whole
  range :inventory_count,                 type: :whole
  range :inventory_price_in_cents,        type: :whole

  param :lat, type: :latitude
  param :lon, type: :longitude
  apply :lat, :lon do |lat, lon|
    scope.distance_from(lat, lon)
  end

  param :geo
  apply :geo do |geo|
    loc = GEO[geo].first.geometry.location
    scope.distance_from(loc.lat, loc.lng)
  end

  mutual [:lat, :lon], exclusive: :geo
end
