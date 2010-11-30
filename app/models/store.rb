class Store < Ohm::Model

  include Ohm::Typecast
  include Ohm::Archive
  include Ohm::ToHash
  include Ohm::CountAll
  include Ohm::Sunspot
  include Ohm::Rails

  attribute :crawled_at,                      Time
  attribute :is_hidden,                       Boolean
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

  archive :crawled_at, [
    :is_hidden,
    :products_count,
    :inventory_count,
    :inventory_price_in_cents,
    :inventory_volume_in_milliliters]

  sunspot do
    integer :store_no
    text :name, :address_line_1, :address_line_2
    boolean :is_hidden
    boolean :has_wheelchair_accessability
    boolean :has_bilingual_services
    boolean :has_product_consultant
    boolean :has_tasting_bar
    boolean :has_beer_cold_room
    boolean :has_special_occasion_permits
    boolean :has_vintages_corner
    boolean :has_parking
    boolean :has_transit_access
    integer :products_count
    integer :inventory_count
    integer :inventory_price_in_cents
    integer :inventory_volume_in_milliliters
    location :geo
  end

  def self.place(attrs)
    if (store = self[attrs[:store_no]])
      store.update(attrs)
    else
      create(attrs)
    end
  end

  def geo
    Struct.new(:lat, :lng).new(latitude, longitude)
  end

  def store_no=(value)
    self.id = value
  end

  def store_no
    id.to_i
  end

  def as_json
    { :store_no => store_no }.merge(to_hash(:id, :is_hidden))
  end

end
