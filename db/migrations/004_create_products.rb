Sequel.migration do

  up do
    create_table :products do
      primary_key :id
      foreign_key :crawl_id

      column :is_dead,                             :boolean,   :default => false, :index => true
      column :name,                                :varchar,   :size => 100
      column :is_discontinued,                     :boolean,   :default => false, :index => true
      column :price_in_cents,                      :integer,   :default => 0
      column :regular_price_in_cents,              :integer,   :default => 0
      column :limited_time_offer_savings_in_cents, :smallint,  :default => 0
      column :limited_time_offer_ends_on,          :date
      column :bonus_reward_miles,                  :smallint,  :default => 0
      column :bonus_reward_miles_ends_on,          :date
      column :stock_type,                          :varchar,   :size => 10
      column :primary_category,                    :varchar,   :size => 32
      column :secondary_category,                  :varchar,   :size => 32
      column :origin,                              :varchar,   :size => 60
      column :package,                             :varchar,   :size => 32
      column :package_unit_type,                   :varchar,   :size => 20
      column :package_unit_volume_in_milliliters,  :smallint,  :default => 0
      column :total_package_units,                 :smallint,  :default => 0
      column :total_package_volume_in_milliliters, :integer,   :default => 0
      column :volume_in_milliliters,               :integer,   :default => 0
      column :alcohol_content,                     :smallint,  :default => 0
      column :price_per_liter_of_alcohol_in_cents, :integer,   :default => 0
      column :price_per_liter_in_cents,            :integer,   :default => 0
      column :inventory_count,                     :bigint,    :default => 0, :index => true
      column :inventory_volume_in_milliliters,     :bigint,    :default => 0
      column :inventory_price_in_cents,            :bigint,    :default => 0
      column :sugar_content,                       :varchar,   :size => 6
      column :producer_name,                       :varchar,   :size => 80
      column :released_on,                         :date
      column :has_value_added_promotion,           :boolean,   :default => false
      column :has_limited_time_offer,              :boolean,   :default => false
      column :has_bonus_reward_miles,              :boolean,   :default => false
      column :is_seasonal,                         :boolean,   :default => false
      column :is_vqa,                              :boolean,   :default => false
      column :is_kosher,                           :boolean,   :default => false
      column :value_added_promotion_description,   :text
      column :description,                         :text
      column :serving_suggestion,                  :text
      column :tasting_note,                        :text
      column :updated_at,                          :timestamp, :null => false, :index => true
      column :created_at,                          :timestamp, :null => false

      full_text_index [
        :name,
        :primary_category,
        :secondary_category,
        :package_unit_type,
        :producer_name,
        :origin]
    end
  end

  down do
    drop_table :products
  end

end
