class Inventory

  include Mongoid::Document
  include Mongoid::Timestamps

  key :product_no, :store_no

  field :is_active,       :type => Boolean, :default => true
  field :crawl_timestamp, :type => Integer
  field :store_geo,       :type => Array
  field :product_tags
  field :store_tags

  # Public
  field :product_no,      :type => Integer
  field :store_no,        :type => Integer
  field :quantity,        :type => Integer
  field :updated_on,      :type => DateTime

  index [[:geo, Mongo::GEO2D]]
  index [[:product_no, Mongo::ASCENDING], [:store_no, Mongo::ASCENDING]], :unique => true
  index [[:crawl_timestamp, Mongo::ASCENDING]]

  embeds_many :changes, :class_name => 'InventoryCrawl'

  referenced_in :product
  referenced_in :store

  def self.commit(page)
    
  end

end
