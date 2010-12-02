class CreateProducts < ActiveRecord::Migration

  def self.up
    create_table :products do |t|
      t.references :crawl
      t.boolean    :is_hidden,                           :default => false
      t.string     :name,                                :limit   => 100
      t.boolean    :is_discontinued,                     :default => false
      t.integer    :price_in_cents,                      :default => 0
      t.integer    :regular_price_in_cents,              :default => 0
      t.integer    :limited_time_offer_savings_in_cents, :default => 0
      t.string     :limited_time_offer_ends_on,          :limit   => 10
      t.integer    :bonus_reward_miles,                  :default => 0
      t.string     :bonus_reward_miles_ends_on,          :limit   => 10
      t.string     :stock_type,                          :limit   => 10
      t.string     :primary_category,                    :limit   => 32
      t.string     :secondary_category,                  :limit   => 32
      t.string     :origin,                              :limit   => 60
      t.string     :package,                             :limit   => 32
      t.string     :package_unit_type,                   :limit   => 20
      t.integer    :package_unit_volume_in_milliliters,  :default => 0
      t.integer    :total_package_units,                 :default => 0
      t.integer    :total_package_volume_in_milliliters, :default => 0
      t.integer    :volume_in_milliliters,               :default => 0
      t.integer    :alcohol_content,                     :default => 0
      t.integer    :price_per_liter_of_alcohol_in_cents, :default => 0
      t.integer    :price_per_liter_in_cents,            :default => 0
      t.integer    :inventory_count,                     :default => 0, :limit => 8
      t.integer    :inventory_volume_in_milliliters,     :default => 0, :limit => 8
      t.integer    :inventory_price_in_cents,            :default => 0, :limit => 8
      t.string     :sugar_content,                       :limit   => 6
      t.string     :producer_name,                       :limit   => 80
      t.string     :released_on,                         :limit   => 10
      t.boolean    :has_limited_time_offer,              :default => false
      t.boolean    :has_bonus_reward_miles,              :default => false
      t.boolean    :is_seasonal,                         :default => false
      t.boolean    :is_vqa,                              :default => false
      t.text       :description
      t.text       :serving_suggestion
      t.text       :tasting_note
      t.timestamps
    end
    add_index :products, :is_discontinued
    add_index :products, :inventory_count
    add_index :products, :updated_at
    add_index :products, :crawl_id
  end

  def self.down
    drop_table :products
  end

end
