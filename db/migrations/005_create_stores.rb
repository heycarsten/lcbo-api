Sequel.migration do

  up do
    create_table :stores do
      primary_key :id
      foreign_key :crawl_id

      column :is_dead,                         :boolean,   :default => false, :index => true
      column :name,                            :varchar,   :size => 50
      column :tags,                            :varchar,   :size => 380
      column :address_line_1,                  :varchar,   :size => 40
      column :address_line_2,                  :varchar,   :size => 40
      column :city,                            :varchar,   :size => 25
      column :postal_code,                     :char,      :size => 6
      column :telephone,                       :char,      :size => 14
      column :fax,                             :char,      :size => 14
      column :latitude,                        :real,      :null => false
      column :longitude,                       :real,      :null => false
      column :latrad,                          :real,      :null => false
      column :lngrad,                          :real,      :null => false
      column :products_count,                  :integer,   :default => 0,     :index => true
      column :inventory_count,                 :bigint,    :default => 0,     :index => true
      column :inventory_price_in_cents,        :bigint,    :default => 0,     :index => true
      column :inventory_volume_in_milliliters, :bigint,    :default => 0,     :index => true
      column :has_wheelchair_accessability,    :boolean,   :default => false
      column :has_bilingual_services,          :boolean,   :default => false
      column :has_product_consultant,          :boolean,   :default => false
      column :has_tasting_bar,                 :boolean,   :default => false
      column :has_beer_cold_room,              :boolean,   :default => false
      column :has_special_occasion_permits,    :boolean,   :default => false
      column :has_vintages_corner,             :boolean,   :default => false
      column :has_parking,                     :boolean,   :default => false
      column :has_transit_access,              :boolean,   :default => false
      Date::DAYNAMES.each do |day|
        column :"#{day.downcase}_open",        :smallint
        column :"#{day.downcase}_close",       :smallint
      end
      column :created_at,                      :timestamp, :null => false, :index => true
      column :updated_at,                      :timestamp, :null => false, :index => true

      index [
        :has_wheelchair_accessability,
        :has_bilingual_services,
        :has_product_consultant,
        :has_tasting_bar,
        :has_beer_cold_room,
        :has_special_occasion_permits,
        :has_vintages_corner,
        :has_parking,
        :has_transit_access ]

      full_text_index [:tags]
    end
  end

  down do
    drop_table :stores
  end

end
