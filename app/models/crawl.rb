class Crawl

  include Mongoid::Document
  include Mongoid::Timestamps

  field :timestamp,                           :type => Integer
  field :state
  field :bot
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

  embeds_many :log_items, :class_name => 'CrawlLogItem'

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

  def self.spawn(params = {})
    if crawl = in_progress.first(params)
      crawl
    else
      create(params.merge(:timestamp => Time.now.to_i))
    end
  end

  def log(message, job = nil, exception = nil)
    h = {}
    h[:message] = message
    h[:job] = job
    if exception
      h[:error_class] = exception.class.to_s
      h[:error_message] = exception.message
      h[:error_backtrace] = exception.backtrace.join("\n")
    end
    log_items.create(h)
  end

  def start!
    return if did_fail || did_start
    update_attributes :did_start => true
  end

  def fail!
    update_attributes :did_fail => true
  end

  def finish!
    return if !did_start || did_fail
    update_attributes :did_finish => true
  end

end
