class Inventory

  include Mongoid::Document
  include Mongoid::Versioning

  key :product_no, :store_no

  field :is_active,       :type => Boolean, :default => true
  field :crawl_timestamp, :type => Integer
  field :product_no,      :type => Integer
  field :store_no,        :type => Integer
  field :quantity,        :type => Integer
  field :updated_on,      :type => DateTime

  index [[:product_no, Mongo::ASCENDING], [:store_no, Mongo::ASCENDING]], :unique => true
  index [[:crawl_timestamp, Mongo::ASCENDING]]

  scope :older_than, lambda { |datetime|
    where(:crawl_timestamp.lt(datetime))
  }

  belongs_to_related :product
  belongs_to_related :store

end
