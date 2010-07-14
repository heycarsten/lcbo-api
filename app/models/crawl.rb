class Crawl

  include Mongoid::Document
  include Mongoid::Timestamps

  field :timestamp,                           :type => Integer
  field :did_start,                           :type => Boolean
  field :did_finish,                          :type => Boolean
  field :did_fail,                            :type => Boolean
  field :total_product_inventory_quantity,    :type => Integer
  field :total_product_volume_in_milliliters, :type => Integer
  field :total_product_price_in_cents,        :type => Integer
  field :total_products,                      :type => Integer
  field :total_stores,                        :type => Integer
  field :uncrawled_product_nos,               :type => Array, :default => []
  field :uncrawled_inventory_product_nos,     :type => Array, :default => []
  field :uncrawled_store_nos,                 :type => Array, :default => []

  index [[:timestamp, Mongo::DESCENDING]], :unique => true

  embeds_many :tasks, :class_name => 'CrawlTask'

  scope :timestamp, lambda { |timestamp|
    where(:timestamp => timestamp.to_i) }

  scope :failed,
    where(:did_fail => true).
    order_by(:timestamp.desc)

  scope :active,
    where(:did_start => true, :did_finish => true, :did_fail => false).
    order_by(:timestamp.desc)

  scope :in_progress,
    where(:did_start => true, :did_finish => false, :did_fail => false).
    order_by(:timestamp.desc)

end
