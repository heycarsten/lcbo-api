class CreateCrawls < ActiveRecord::Migration

  def self.up
    create_table :crawls do |t|
      t.references :crawl_event
      t.string     :state,                                         :length => 20
      t.text       :added_store_nos
      t.text       :removed_store_nos
      t.text       :added_product_nos
      t.text       :removed_product_nos
      t.integer    :total_products,                                :default => 0
      t.integer    :total_stores,                                  :default => 0
      t.integer    :total_inventories,                             :default => 0
      t.integer    :total_product_inventory_count,                 :default => 0
      t.integer    :total_product_inventory_volume_in_milliliters, :default => 0
      t.integer    :total_product_inventory_price_in_cents,        :default => 0
      t.integer    :total_jobs,                                    :default => 0
      t.integer    :total_finished_jobs,                           :default => 0
      t.timestamps
    end
    add_index :crawls, :state
    add_index :crawls, :updated_at
    add_index :crawls, :created_at
  end

  def self.down
    drop_table :crawls
  end

end
