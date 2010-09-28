class Crawl < Ohm::Model

  STATES = %w[ started finished failed ]

  include Ohm::Typecast
  include Ohm::Callbacks
  include Ohm::Timestamping
  include Ohm::ExtraValidations

  attribute :timestamp,                           Integer
  attribute :state,                               String
  attribute :job,                                 String
  attribute :total_product_inventory_quantity,    Integer
  attribute :total_product_volume_in_milliliters, Integer
  attribute :total_product_price_in_cents,        Integer

  list :product_nos
  list :store_nos
  list :inventory_product_nos
  list :completed_product_nos
  list :completed_store_nos
  list :completed_inventory_product_nos

  index :timestamp
  index :state

  list :logs, CrawlLog

  before :create, :set_defaults

  def self.in_progress
    all.find(:state => 'started').sort_by(:timestamp, :order => 'DESC').first
  end

  def self.spawn
    (crawl = in_progress) ? crawl : create(:timestamp => Time.now.to_i)
  end

  def log(message, job = nil, exception = nil)
    h = {}
    h[:message] = message
    if job
      h[:job] = job
      self.job = job
    end
    if exception
      h[:error_class] = exception.class.to_s
      h[:error_message] = exception.message
      h[:error_backtrace] = exception.backtrace.join(?\n)
    end
    logs << CrawlLogItem.create(h)
    save
  end

  protected

  def validate
    super
    assert_member :state, STATES
  end

  def set_defaults
    self.state = 'started' unless state
    self.total_product_inventory_quantity = 0 unless total_product_inventory_quantity
    self.total_product_volume_in_milliliters = 0 unless total_product_volume_in_milliliters
    self.total_product_price_in_cents = 0 unless total_product_price_in_cents
  end

end
