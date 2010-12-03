class CreateInventoryRevisions < ActiveRecord::Migration

  def self.up
    create_table :inventory_revisions, :id => false, :primary_key => [:updated_on, :product_id, :store_id] do |t|
      t.references :product, :store
      t.integer    :quantity,   :default => 0
      t.string     :updated_on, :limit => 10
    end
    add_index :inventory_revisions, [:updated_on, :product_id, :store_id], :unique => true, :name => 'inventory_revisions_seq_ups'
  end

  def self.down
    drop_table :inventory_revisions
  end

end
