class CreateInventoryRevisions < ActiveRecord::Migration

  def self.up
    create_table :inventory_revisions do |t|
      t.references :crawl, :product, :store
      t.integer    :quantity,   :default => 0
      t.string     :updated_on, :limit => 10
    end
    add_index :inventory_revisions, [:crawl_id, :product_id, :store_id], :unique => true, :name => 'inventory_revisions_seq_cps'
  end

  def self.down
    drop_table :inventory_revisions
  end

end
