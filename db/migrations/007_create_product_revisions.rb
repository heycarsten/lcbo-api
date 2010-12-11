Sequel.migration do

  up do
    create_table :product_revisions do
      column :crawl_id, :integer
      column :product_id, :integer
      primary_key [:product_id, :crawl_id]
      column :is_dead,                             :boolean,   :default => false
      column :is_discontinued,                     :boolean,   :default => false
      column :price_in_cents,                      :integer,   :default => 0
      column :regular_price_in_cents,              :integer,   :default => 0
      column :limited_time_offer_savings_in_cents, :smallint,  :default => 0
      column :limited_time_offer_ends_on,          :date
      column :bonus_reward_miles,                  :smallint,  :default => 0
      column :bonus_reward_miles_ends_on,          :date
      column :inventory_count,                     :bigint,    :default => 0
      column :inventory_volume_in_milliliters,     :bigint,    :default => 0
      column :inventory_price_in_cents,            :bigint,    :default => 0
      column :has_value_added_promotion,           :boolean,   :default => false
      column :value_added_promotion_description,   :text
      column :has_limited_time_offer,              :boolean,   :default => false
      column :has_bonus_reward_miles,              :boolean,   :default => false
    end
  end

  down do
    drop_table :product_revisions
  end

end