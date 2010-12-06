class CreateStoreRevisions < ActiveRecord::Migration

  def self.up
    create_table :store_revisions, :id => false, :primary_key => [:crawl_id, :store_id] do |t|
      t.references :crawl, :store
      t.boolean :is_hidden
      t.integer :products_count
      t.integer :inventory_count
      t.integer :inventory_price_in_cents
      t.integer :inventory_volume_in_milliliters
      Date::DAYNAMES.each do |day|
        t.integer :"#{day.downcase}_open"
        t.integer :"#{day.downcase}_close"
      end
      t.timestamps
    end
    add_index :store_revisions, [:crawl_id, :store_id], :unique => true
  end

  def self.down
    drop_table :store_revisions
  end

end
