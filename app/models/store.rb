class Store < Ohm::Model

  ARCHIVE = [
    :is_hidden,
    :products_count,
    :inventory_count,
    :inventory_price_in_cents,
    :inventory_volume_in_milliliters]

  include Ohm::Typecast
  include Ohm::Callbacks

  attribute :crawled_at,                      Time
  attribute :store_no,                        Integer
  attribute :name,                            String
  attribute :address_line_1,                  String
  attribute :address_line_2,                  String
  attribute :city,                            String
  attribute :postal_code,                     String
  attribute :telephone,                       String
  attribute :fax,                             String
  attribute :latitude,                        Float
  attribute :longitude,                       Float
  attribute :products_count,                  Integer
  attribute :inventory_count,                 Integer
  attribute :inventory_price_in_cents,        Integer
  attribute :inventory_volume_in_milliliters, Integer
  attribute :has_wheelchair_accessability,    Boolean
  attribute :has_bilingual_services,          Boolean
  attribute :has_product_consultant,          Boolean
  attribute :has_tasting_bar,                 Boolean
  attribute :has_beer_cold_room,              Boolean
  attribute :has_special_occasion_permits,    Boolean
  attribute :has_vintages_corner,             Boolean
  attribute :has_parking,                     Boolean
  attribute :has_transit_access,              Boolean
  Date::DAYNAMES.each do |day|
    attribute :"#{day.downcase}_open",        Integer
    attribute :"#{day.downcase}_close",       Integer
  end

  index :store_no
  index :crawled_at

end
