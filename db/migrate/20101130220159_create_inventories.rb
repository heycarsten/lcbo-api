class CreateInventories < ActiveRecord::Migration

  def self.up
    create_table :inventories, :id => false, :primary_key => [:product_id, :store_id] do |t|
      t.references :product, :store, :crawl
      t.boolean    :is_hidden,  :default => false
      t.integer    :quantity,   :default => 0
      t.string     :updated_on, :limit => 10
      t.timestamps
    end
    add_index :inventories, [:product_id, :store_id], :unique => true
    add_index :inventories, :crawl_id
    add_index :inventories, :is_hidden
  end

  def self.down
    drop_table :inventories
  end

end
