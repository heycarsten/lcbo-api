Sequel.migration do

  up do
    create_table :products do
      primary_key :id
      foreign_key :crawl_id
      boolean     :is_hidden,                           :default => false
      string      :name,                                :size    => 100
      boolean     :is_discontinued,                     :default => false, :index => true
      integer     :price_in_cents,                      :default => 0
      integer     :regular_price_in_cents,              :default => 0
      integer     :limited_time_offer_savings_in_cents, :default => 0
      date        :limited_time_offer_ends_on
      integer     :bonus_reward_miles,                  :default => 0
      date        :bonus_reward_miles_ends_on
      string      :stock_type,                          :size    => 10
      string      :primary_category,                    :size    => 32
      string      :secondary_category,                  :size    => 32
      string      :origin,                              :size    => 60
      string      :package,                             :size    => 32
      string      :package_unit_type,                   :size    => 20
      integer     :package_unit_volume_in_milliliters,  :default => 0
      integer     :total_package_units,                 :default => 0
      integer     :total_package_volume_in_milliliters, :default => 0
      integer     :volume_in_milliliters,               :default => 0
      integer     :alcohol_content,                     :default => 0
      integer     :price_per_liter_of_alcohol_in_cents, :default => 0
      integer     :price_per_liter_in_cents,            :default => 0
      integer     :inventory_count,                     :default => 0, :size => 8, :index => true
      integer     :inventory_volume_in_milliliters,     :default => 0, :size => 8
      integer     :inventory_price_in_cents,            :default => 0, :size => 8
      string      :sugar_content,                       :size    => 6
      string      :producer_name,                       :size    => 80
      date        :released_on
      boolean     :has_limited_time_offer,              :default => false
      boolean     :has_bonus_reward_miles,              :default => false
      boolean     :is_seasonal,                         :default => false
      boolean     :is_vqa,                              :default => false
      boolean     :is_kosher,                           :default => false
      text        :description
      text        :serving_suggestion
      text        :tasting_note
      datetime    :updated_at,                          :null => false, :index => true
      datetime    :created_at,                          :null => false
    end
  end

  down do
    drop_table :products
  end

end
