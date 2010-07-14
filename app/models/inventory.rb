class Inventory

  include Mongoid::Document
  include FieldTracking

  tracked_fields :quantity, :updated_on

  key :product_no, :store_no

  field :is_active,       :type => Boolean, :default => true
  field :crawl_timestamp, :type => Integer
  field :product_no,      :type => Integer
  field :store_no,        :type => Integer
  field :quantity,        :type => Integer
  field :updated_on,      :type => DateTime

  index [[:product_no, Mongo::ASCENDING], [:store_no, Mongo::ASCENDING]], :unique => true

  belongs_to_related :product
  belongs_to_related :store

  def self.commit(crawl, fields)
    if (inventory = where(:product_no => fields[:product_no], :store_no => fields[:store_no]).first)
      inventory.commit(crawl, fields)
    else
      init(crawl, fields)
    end
  end

  def self.init(crawl, fields)
    inventory = new(fields)
    inventory.active_crawl = crawl
    inventory.save
  end

  def commit(crawl, fields)
    self.active_crawl = crawl
    update_attributes(fields)
  end

end
