Sequel.migration do

  up do
    create_table :inventory_revisions do |t|
      column :product_id, :integer
      column :store_id,   :integer
      column :updated_on, :date,     :index => true
      column :quantity,   :smallint, :default => 0
      index [:product_id, :store_id]
    end
  end

  down do
    drop_table :inventory_revisions
  end

end
