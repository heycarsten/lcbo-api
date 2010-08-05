class Crawl

  include Mongoid::Document
  include Mongoid::Timestamps

  field :timestamp,                           :type => Integer
  field :state
  field :did_start,                           :type => Boolean, :default => false
  field :did_finish,                          :type => Boolean, :default => false
  field :did_fail,                            :type => Boolean, :default => false
  field :total_product_inventory_quantity,    :type => Integer, :default => 0
  field :total_product_volume_in_milliliters, :type => Integer, :default => 0
  field :total_product_price_in_cents,        :type => Integer, :default => 0
  field :existing_product_nos,                :type => Array,   :default => []
  field :existing_store_nos,                  :type => Array,   :default => []
  field :crawled_product_nos,                 :type => Array,   :default => []
  field :crawled_store_nos,                   :type => Array,   :default => []
  field :new_product_nos,                     :type => Array,   :default => []
  field :new_store_nos,                       :type => Array,   :default => []
  field :crawled_product_nos,                 :type => Array,   :default => []
  field :crawled_store_nos,                   :type => Array,   :default => []
  field :crawled_inventory_product_nos,       :type => Array,   :default => []

  index [[:timestamp, Mongo::DESCENDING]], :unique => true

  embeds_many :log_items, :class_name => 'CrawlLogItem'

  scope :timestamp, lambda { |timestamp|
    where(:timestamp => timestamp.to_i) }

  scope :finished,
    where(:did_start => true, :did_finish => true, :did_fail => false).
    order_by(:timestamp.desc)

  scope :failed,
    where(:did_fail => true).
    order_by(:timestamp.desc)

  scope :in_progress,
    where(:did_start => true, :did_finish => false, :did_fail => false).
    order_by(:timestamp.desc)

  def self.spawn
    (crawl = in_progress.first) ? crawl : create(:timestamp => Time.now.to_i)
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
    save
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
