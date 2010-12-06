Sequel.migration do

  up do
    create_table :stores do
      primary_key :id
      foreign_key :crawl_id
      boolean     :is_hidden,                       :default => false, :index => true
      string      :name,                            :size    => 50
      string      :address_line_1,                  :size    => 40
      string      :address_line_2,                  :size    => 40
      string      :city,                            :size    => 25
      string      :postal_code,                     :size    => 6
      string      :telephone,                       :size    => 14
      string      :fax,                             :size    => 14
      integer     :products_count,                  :default => 0
      integer     :inventory_count,                 :default => 0, :size => 8
      integer     :inventory_price_in_cents,        :default => 0, :size => 8
      integer     :inventory_volume_in_milliliters, :default => 0, :size => 8
      boolean     :has_wheelchair_accessability,    :default => false
      boolean     :has_bilingual_services,          :default => false
      boolean     :has_product_consultant,          :default => false
      boolean     :has_tasting_bar,                 :default => false
      boolean     :has_beer_cold_room,              :default => false
      boolean     :has_special_occasion_permits,    :default => false
      boolean     :has_vintages_corner,             :default => false
      boolean     :has_parking,                     :default => false
      boolean     :has_transit_access,              :default => false
      Date::DAYNAMES.each do |day|
        integer :"#{day.downcase}_open"
        integer :"#{day.downcase}_close"
      end
      datetime :created_at, :null => false
      datetime :updated_at, :null => false
      #####################################################################
      # TODO: Add spatial index
      # point :geo, :srid => 4326, :null => false, :index => true
      #####################################################################
    end
  end

  down do
    drop_table :stores
  end

end
