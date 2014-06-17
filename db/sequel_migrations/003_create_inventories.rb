Sequel.migration do

  up do
    create_table :inventories do |t|
      column :product_id,      :integer
      column :store_id,        :integer
      foreign_key :crawl_id
      column :is_dead,         :boolean,   :default => false, :index => true
      column :quantity,        :smallint,  :default => 0
      column :updated_on,      :date
      column :created_at,      :timestamp, :null => false
      column :updated_at,      :timestamp, :null => false
      primary_key [:product_id, :store_id]
    end
  end

  down do
    drop_table :inventories
  end

end
