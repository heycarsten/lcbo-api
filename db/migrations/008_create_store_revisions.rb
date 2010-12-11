Sequel.migration do

  up do
    create_table :store_revisions do
      column :crawl_id, :integer
      column :store_id, :integer
      primary_key [:store_id, :crawl_id]
      column :is_dead,                         :boolean,   :default => false
      column :products_count,                  :integer,   :default => 0
      column :inventory_count,                 :bigint,    :default => 0
      column :inventory_price_in_cents,        :bigint,    :default => 0
      column :inventory_volume_in_milliliters, :bigint,    :default => 0
      Date::DAYNAMES.each do |day|
        column :"#{day.downcase}_open",        :smallint
        column :"#{day.downcase}_close",       :smallint
      end
    end
  end

  down do
    drop_table :store_revisions
  end

end
