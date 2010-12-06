class CreateInventoryRevisions < ActiveRecord::Migration

  def self.up
    create_table :inventory_revisions, :id => false do |t|
      t.references :store, :product
      t.date       :updated_on
      t.integer    :quantity,   :default => 0
    end
    add_index :inventory_revisions, [:product_id, :store_id, :updated_on], :unique => true, :name => 'inventory_revisions_seq_psu'
  end

  def self.down
    drop_table :inventory_revisions
  end

end
