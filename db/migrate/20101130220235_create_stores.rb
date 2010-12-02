class CreateStores < ActiveRecord::Migration

  def self.up
    create_table :stores do |t|
      t.references :crawl
      t.boolean  :is_hidden,                       :default => false
      t.string   :name,                            :limit   => 50
      t.string   :address_line_1,                  :limit   => 40
      t.string   :address_line_2,                  :limit   => 40
      t.string   :city,                            :limit   => 25
      t.string   :postal_code,                     :limit   => 6
      t.string   :telephone,                       :limit   => 14
      t.string   :fax,                             :limit   => 14
      t.integer  :products_count,                  :default => 0
      t.integer  :inventory_count,                 :default => 0, :limit => 8
      t.integer  :inventory_price_in_cents,        :default => 0, :limit => 8
      t.integer  :inventory_volume_in_milliliters, :default => 0, :limit => 8
      t.boolean  :has_wheelchair_accessability,    :default => false
      t.boolean  :has_bilingual_services,          :default => false
      t.boolean  :has_product_consultant,          :default => false
      t.boolean  :has_tasting_bar,                 :default => false
      t.boolean  :has_beer_cold_room,              :default => false
      t.boolean  :has_special_occasion_permits,    :default => false
      t.boolean  :has_vintages_corner,             :default => false
      t.boolean  :has_parking,                     :default => false
      t.boolean  :has_transit_access,              :default => false
      Date::DAYNAMES.each do |day|
        t.integer :"#{day.downcase}_open"
        t.integer :"#{day.downcase}_close"
      end
      t.point :geo, :srid => 4326, :null => false
      t.timestamps
    end
    add_index :stores, :is_hidden
    add_index :stores, :crawl_id
    add_index :stores, :geo, :spatial => true
  end

  def self.down
    drop_table :stores
  end

end
