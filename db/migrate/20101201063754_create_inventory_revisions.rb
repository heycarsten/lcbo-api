class CreateInventoryRevisions < ActiveRecord::Migration

  def self.up
    create_table :inventory_revisions do |t|
      t.references :inventory
      t.integer    :quantity,   :default => 0
      t.string     :updated_on, :limit => 10
    end
    add_index :inventory_revisions, :updated_on
  end

  def self.down
    drop_table :inventory_revisions
  end

end
