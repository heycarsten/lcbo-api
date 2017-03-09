class API::V2::ProductResource < API::V2::BaseResource
  attributes \
    :catalog,
    :name,
    :is_dead,
    :is_discontinued,
    :is_seasonal,
    :is_vqa,
    :is_ocb,
    :is_kosher,
    :price_in_cents,
    :regular_price_in_cents,
    :limited_time_offer_savings_in_cents,
    :limited_time_offer_ends_on,
    :bonus_reward_miles,
    :bonus_reward_miles_ends_on,
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
    :value_added_promotion_description,
    :description,
    :serving_suggestion,
    :tasting_note,
    :image_thumb_url,
    :image_url,
    :varietal,
    :style,
    :sugar_in_grams_per_liter,
    :clearance_sale_savings_in_cents,
    :has_clearance_sale,
    :created_at,
    :updated_at,
    :category

  def self.records(opts = {})
    Product.where(is_dead: false)
  end

  def self.sortable_fields(context)
    [
      :id,
      :price_in_cents,
      :regular_price_in_cents,
      :limited_time_offer_savings_in_cents,
      :limited_time_offer_ends_on,
      :bonus_reward_miles,
      :bonus_reward_miles_ends_on,
      :package_unit_volume_in_milliliters,
      :total_package_units,
      :total_package_volume_in_milliliters,
      :volume_in_milliliters,
      :alcohol_content,
      :price_per_liter_of_alcohol_in_cents,
      :price_per_liter_in_cents,
      :inventory_count,
      :inventory_volume_in_milliliters,
      :inventory_price_in_cents,
      :released_on,
      :created_at,
      :updated_at
    ]
  end

  filter :include_dead, apply: ->(records, value, _options) {
    records.where(is_dead: [true, false])
  }

  def catalog
    Product::CATALOG_REFS.invert[@model.catalog_refs.last]
  end

  def alcohol_content
    (@model.alcohol_content * 1000.0).round(2)
  end

  # def quantity
  #   object.try(:quantity)
  # end

  # def reported_on
  #   object.try(:reported_on)
  # end

  # def distance_in_meters
  #   object.try(:distance_in_meters)
  # end

  # def filter(keys)
  #   unless object.respond_to?(:quantity)
  #     keys.delete(:quantity)
  #   end

  #   unless object.respond_to?(:reported_on)
  #     keys.delete(:reported_on)
  #   end

  #   unless object.respond_to?(:distance_in_meters)
  #     keys.delete(:distance_in_meters)
  #   end

  #   unless scope && scope[:include_dead]
  #     keys.delete(:is_dead)
  #   end

  #   keys
  # end

  # def attributes
  #   h = super

  #   h[:links] = {}.tap do |links|
  #     links[:producer] = object.producer_id.to_s if object.producer_id

  #     category_ids = object.category_ids || []

  #     links[:category]   = category_ids.last.to_s unless category_ids.empty?
  #     links[:categories] = category_ids.map(&:to_s)
  #   end

  #   h.delete(:links) if h[:links].empty?

  #   h
  # end
end
