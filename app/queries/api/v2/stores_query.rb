class API::V2::StoresQuery < API::V2::APIQuery
  model { Store }

  has_pagination
  has_include_dead

  by :id

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
    :has_transit_access

  range :distance_in_meters,              type: :whole
  range :inventory_volume_in_milliliters, type: :whole
  range :products_count,                  type: :whole
  range :inventory_count,                 type: :whole
  range :inventory_price_in_cents,        type: :whole

  param :product_id, type: :id do |product_id|
    scope.joins(:inventories).
      select('stores.*, inventories.quantity, inventories.reported_on').
      where('inventories.product_id' => product.id)
  end

  param :product_ids, type: :id, array: :always, limit: 10 do |ids|
    scope.with_product_ids(ids)
  end

  exclusive :product_id, :product_ids

  def product
    @product ||= begin
      if (id = params[:product_id])
        Product.find(id)
      else
        nil
      end
    end
  end

  def products
    @products ||= begin
      if (ids = params[:product_ids])
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
