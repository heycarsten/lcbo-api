Sequel.migration do

  up do
    create_table :inventory_revisions do |t|
      column :product_id, :integer
      column :store_id,   :integer
      column :updated_on, :date
      column :is_hidden,  :boolean,  :default => false
      column :quantity,   :smallint, :default => 0
      primary_key [:product_id, :store_id, :updated_on]
    end
  end

  down do
    drop_table :inventory_revisions
  end

end
