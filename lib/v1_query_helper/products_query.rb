module V1QueryHelper
  class ProductsQuery < Query
    def initialize(request, params)
      super
      self.q = params[:q] if params[:q].present?
      validate
    end

    def self.max_limit
      200
    end

    def self.filterable_fields
      %w[
      is_dead
      is_discontinued
      has_value_added_promotion
      has_limited_time_offer
      has_bonus_reward_miles
      is_seasonal
      is_vqa
      is_kosher ]
    end

    def self.sortable_fields
      %w[
      id
      price_in_cents
      regular_price_in_cents
      limited_time_offer_savings_in_cents
      limited_time_offer_ends_on
      bonus_reward_miles
      bonus_reward_miles_ends_on
      package_unit_volume_in_milliliters
      total_package_units
      total_package_volume_in_milliliters
      volume_in_milliliters
      alcohol_content
      price_per_liter_of_alcohol_in_cents
      price_per_liter_in_cents
      inventory_count
      inventory_volume_in_milliliters
      inventory_price_in_cents
      released_on ]
    end

    def self.order
      'inventory_volume_in_milliliters.desc'
    end

    def self.where
      []
    end

    def self.where_not
      %w[ is_dead ]
    end

    def scope
      if has_fulltext?
        model.search(q)
      else
        model
      end.

      where(filter_hash).
      order(*order)
    end

    def as_json
      h = super
      h[:result] = page_scope.all.map { |product| serialize(product) }

      h[:suggestion] = if 0 == h[:result].size
        has_fulltext? ? Fuzz[:products, q] : nil
      else
        nil
      end

      h
    end
  end
end
