module V1
  module QueryHelper
    class ProductsQuery < Query
      attr_accessor :store

      def initialize(request, params)
        super
        self.q = params[:q] if params[:q].present?
        self.store = Store.find(params[:store_id]) if params[:store_id].present?
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
        is_ocb
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
        s = if has_fulltext?
          model.search(q)
        else
          model
        end

        if store
          s = s.joins(:inventories).
            select('products.*, inventories.quantity, inventories.reported_on').
            where('inventories.store_id' => store.id)
        end

        s = s.where(filter_hash)
        s = s.reorder(nil) if has_fulltext? && order.any?
        s = s.order(*order)
        s
      end

      def as_json
        h = super
        h[:result] = page_scope.all.map { |product| serialize(product) }

        h[:store] = StoresQuery.serialize(store) if store

        h[:suggestion] = if 0 == h[:result].size
          has_fulltext? ? Fuzz[:products, q] : nil
        else
          nil
        end

        h
      end
    end
  end
end
