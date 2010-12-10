Sequel.migration do

  up do
    create_table :crawls do
      primary_key :id
      foreign_key :crawl_event_id
      column :state,                                         :varchar,   :size => 20, :index => true
      column :task,                                          :varchar,   :size => 60
      column :total_products,                                :integer,   :default => 0
      column :total_stores,                                  :integer,   :default => 0
      column :total_inventories,                             :integer,   :default => 0
      column :total_product_inventory_count,                 :bigint,    :default => 0
      column :total_product_inventory_volume_in_milliliters, :bigint,    :default => 0
      column :total_product_inventory_price_in_cents,        :bigint,    :default => 0
      column :total_jobs,                                    :integer,   :default => 0
      column :total_finished_jobs,                           :integer,   :default => 0
      column :created_at,                                    :timestamp, :null => false, :index => true
      column :updated_at,                                    :timestamp, :null => false, :index => true
    end
  end

  down do
    drop_table :crawls
  end

end
