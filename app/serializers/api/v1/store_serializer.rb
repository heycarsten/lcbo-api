class Api::V1::StoreSerializer < ApplicationSerializer
  DUMP_COLS = [
    :id,
    :is_dead,
    :name,
    :tags,
    :address_line_1,
    :address_line_2,
    :city,
    :postal_code,
    :telephone,
    :fax,
    :latitude,
    :longitude,
    :products_count,
    :inventory_count,
    :inventory_price_in_cents,
    :inventory_volume_in_milliliters,
    :has_wheelchair_accessability,
    :has_bilingual_services,
    :has_product_consultant,
    :has_tasting_bar,
    :has_beer_cold_room,
    :has_special_occasion_permits,
    :has_vintages_corner,
    :has_parking,
    :has_transit_access,
    :sunday_open,
    :sunday_close,
    :monday_open,
    :monday_close,
    :tuesday_open,
    :tuesday_close,
    :wednesday_open,
    :wednesday_close,
    :thursday_open,
    :thursday_close,
    :friday_open,
    :friday_close,
    :saturday_open,
    :saturday_close,
    :updated_at
  ]

  attributes *(DUMP_COLS + [
    :quantity,
    :updated_on,
    :distance_in_meters,
    :store_no
  ])

  def store_no
    object.id
  end

  def quantity
    object.try(:quantity)
  end

  def updated_on
    object.try(:updated_on)
  end

  def distance_in_meters
    object.try(:distance_in_meters)
  end

  def filter(keys)
    if scope == :csv
      keys.delete(:store_no)
    end

    unless object.respond_to?(:quantity)
      keys.delete(:quantity)
    end

    unless object.respond_to?(:updated_on)
      keys.delete(:updated_on)
    end

    unless object.respond_to?(:distance_in_meters)
      keys.delete(:distance_in_meters)
    end

    keys
  end
end
