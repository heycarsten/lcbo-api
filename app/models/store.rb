class Store

  include Mongoid::Document
  include Mongoid::Timestamps

  key :store_no

  field :is_active,                       :type => Boolean, :default => true
  field :crawl_timestamp,                 :type => Integer
  field :geo,                             :type => Array

  # Public
  field :store_no,                        :type => Integer
  field :name
  field :address_line_1
  field :address_line_2
  field :city
  field :postal_code
  field :telephone
  field :fax
  field :latitude,                        :type => Float
  field :longitude,                       :type => Float
  field :products_count,                  :type => Integer
  field :inventory_count,                 :type => Integer
  field :inventory_price_in_cents,        :type => Integer
  field :inventory_volume_in_milliliters, :type => Integer
  field :has_wheelchair_accessability
  field :has_bilingual_services
  field :has_product_consultant
  field :has_tasting_bar
  field :has_beer_cold_room
  field :has_special_occasion_permits
  field :has_vintages_corner
  field :has_parking
  field :has_transit_access
  Date::DAYNAMES.each do |day|
    field :"#{day.downcase}_open",        :type => Integer
    field :"#{day.downcase}_close",       :type => Integer
  end

  index [[:store_no, Mongo::ASCENDING]], :unique => true
  index [[:geo, Mongo::GEO2D]]
  index [[:products_count, Mongo::DESCENDING]]
  index [[:inventory_count, Mongo::DESCENDING]]
  index [[:inventory_price_in_cents, Mongo::DESCENDING]]
  index [[:inventory_volume_in_milliliters, Mongo::DESCENDING]]
  index [[:crawl_timestamp, Mongo::ASCENDING]]

  scope :needing_update, lambda {
    where(:updated_at.lt => 12.hours.ago) }

  references_many :inventories

  before_save :update_geo

  after_save do |store|
    store.inventories.update(:is_active => false) if !store.is_active
  end

  def has_geo?
    latitude && longitude
  end

  protected

  def update_geo
    self.geo = [self.longitude, self.latitude] if has_geo?
  end

end
