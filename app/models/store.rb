class Store

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning

  key :store_no

  field :is_active,                       :type => Boolean, :default => true
  field :crawl_timestamp,                 :type => Integer
  field :store_no,                        :type => Integer
  field :latitude,                        :type => Float
  field :longitude,                       :type => Float
  field :geo,                             :type => Array
  field :name
  field :address_line_1
  field :address_line_2
  field :postal_code
  field :city
  field :telephone
  field :fax
  field :products_count,                  :type => Integer
  field :inventory_count,                 :type => Integer
  field :inventory_price_in_cents,        :type => Integer
  field :inventory_volume_in_milliliters, :type => Integer
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

  scope :older_than, lambda { |datetime|
    where(:crawl_timestamp.lt(datetime))
  }

  has_many_related :inventories

  before_save :update_geo

  def has_geo?
    latitude && longitude
  end

  protected

  def update_geo
    self.geo = [self.longitude, self.latitude] if has_geo?
  end

end
