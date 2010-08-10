class Inventory

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Archive

  key :product_no, :store_no

  field :is_active,       :type => Boolean, :default => true
  field :crawl_timestamp, :type => Integer
  field :store_geo,       :type => Array

  # Public
  field :product_no,      :type => Integer
  field :store_no,        :type => Integer
  field :quantity,        :type => Integer
  field :updated_on,      :type => DateTime

  index [[:geo, Mongo::GEO2D]]
  index [[:geo, Mongo::GEO2D], [:product_no, Mongo::ASCENDING]]
  index [[:product_no, Mongo::ASCENDING], [:store_no, Mongo::ASCENDING]], :unique => true

  archive :crawl_timestamp, [:quantity, :updated_on, :is_active]

  def self.commit(crawl, payload)
    payload
  end

end
