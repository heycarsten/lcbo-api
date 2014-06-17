PRODUCT_COLS = [
  :price_in_cents,
  :regular_price_in_cents,
  :limited_time_offer_savings_in_cents,
  :limited_time_offer_ends_on,
  :bonus_reward_miles,
  :bonus_reward_miles_ends_on,
  :stock_type,
  :primary_category,
  :secondary_category,
  :package_unit_volume_in_milliliters,
  :volume_in_milliliters,
  :alcohol_content,
  :price_per_liter_of_alcohol_in_cents,
  :price_per_liter_in_cents,
  :inventory_count,
  :inventory_volume_in_milliliters,
  :inventory_price_in_cents,
  :released_on]

Sequel.migration do
  up do
    alter_table :products do
      PRODUCT_COLS.each { |col| drop_index(col) }
      PRODUCT_COLS.each { |col| add_index(col, :nulls => :last) }
    end
  end
end