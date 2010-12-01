class CreateInventories < ActiveRecord::Migration

  def self.up
    create_table :inventories, :primary_key => false do |t|
      t.references :product, :store
      t.datetime   :crawled_at
      t.boolean    :is_hidden,  :default => false
      t.integer    :quantity,   :default => 0
      t.string     :updated_on, :limit => 10
    end
    add_index :inventories, [:product_id, :store_id], :unique => true
    add_index :inventories, :is_hidden
  end

  def self.down
    drop_table :inventories
  end

end
