class API::V2::ProductSerializer < ApplicationSerializer
  attributes \
    :id,
    :is_dead,
    :name,
    :tags,
    :is_discontinued,
    :price_in_cents,
    :regular_price_in_cents,
    :limited_time_offer_savings_in_cents,
    :limited_time_offer_ends_on,
    :bonus_reward_miles,
    :bonus_reward_miles_ends_on,
    :stock_type,
    :origin,
    :package,
    :package_unit_type,
    :package_unit_volume_in_milliliters,
    :total_package_units,
    :volume_in_milliliters,
    :alcohol_content,
    :price_per_liter_of_alcohol_in_cents,
    :price_per_liter_in_cents,
    :inventory_count,
    :inventory_volume_in_milliliters,
    :inventory_price_in_cents,
    :sugar_content,
    :released_on,
    :has_value_added_promotion,
    :has_limited_time_offer,
    :has_bonus_reward_miles,
    :is_seasonal,
    :is_vqa,
    :is_kosher,
    :value_added_promotion_description,
    :description,
    :serving_suggestion,
    :tasting_note,
    :updated_at,
    :image_thumb_url,
    :image_url,
    :varietal,
    :style,
    :sugar_in_grams_per_liter,
    :clearance_sale_savings_in_cents,
    :has_clearance_sale,
    :quantity,
    :reported_on,
    :created_at,
    :updated_at,
    :distance_in_meters,
    :category

  def id
    object.id.to_s
  end

  def quantity
    object.try(:quantity)
  end

  def reported_on
    object.try(:reported_on)
  end

  def distance_in_meters
    object.try(:distance_in_meters)
  end

  def filter(keys)
    unless object.respond_to?(:quantity)
      keys.delete(:quantity)
    end

    unless object.respond_to?(:reported_on)
      keys.delete(:reported_on)
    end

    unless object.respond_to?(:distance_in_meters)
      keys.delete(:distance_in_meters)
    end

    keys
  end

  def attributes
    h = super

    h[:links] = {}.tap do |links|
      links[:producer] = object.producer_id.to_s if object.producer_id

      category_ids = object.category_ids || []

      links[:category]   = category_ids.last.to_s unless category_ids.empty?
      links[:categories] = category_ids.map(&:to_s)
    end

    h.delete(:links) if h[:links].empty?

    h
  end
end
