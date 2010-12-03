class CreateProductRevisions < ActiveRecord::Migration

  def self.up
    create_table :product_revisions do |t|
      t.references :crawl, :product
      t.boolean :is_hidden
      t.boolean :is_discontinued
      t.integer :price_in_cents,                      :default => 0
      t.integer :regular_price_in_cents,              :default => 0
      t.integer :limited_time_offer_savings_in_cents, :default => 0
      t.string  :limited_time_offer_ends_on,          :limit   => 10
      t.integer :bonus_reward_miles,                  :default => 0
      t.string  :bonus_reward_miles_ends_on,          :limit   => 10
      t.integer :inventory_count,                     :default => 0
      t.integer :inventory_volume_in_milliliters,     :default => 0
      t.integer :inventory_price_in_cents,            :default => 0
      t.boolean :has_limited_time_offer,              :default => false
      t.boolean :has_bonus_reward_miles,              :default => false
      t.timestamps
    end
    add_index :product_revisions, [:product_id, :crawl_id], :unique => true
  end

  def self.down
    drop_table :product_revisions
  end

end
