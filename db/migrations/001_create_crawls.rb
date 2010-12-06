Sequel.migration do

  up do
    create_table :crawls do
      primary_key :id
      foreign_key :crawl_event_id
      string  :state,                                         :size => 20, :null => false, :index => true
      integer :total_products,                                :default => 0
      integer :total_stores,                                  :default => 0
      integer :total_inventories,                             :default => 0
      integer :total_product_inventory_count,                 :default => 0, :size => 8
      integer :total_product_inventory_volume_in_milliliters, :default => 0, :size => 8
      integer :total_product_inventory_price_in_cents,        :default => 0, :size => 8
      integer :total_jobs,                                    :default => 0
      integer :total_finished_jobs,                           :default => 0
      datetime :created_at,                                   :null => false, :index => true
      datetime :updated_at,                                   :null => false, :index => true
    end
  end

  down do
    drop_table :crawls
  end

end
