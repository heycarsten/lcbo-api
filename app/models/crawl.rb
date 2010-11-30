class Crawl < Ohm::Model

  include Ohm::Typecast
  include Ohm::Timestamping
  include Ohm::ExtraValidations
  include Ohm::Rails

  class StateError < StandardError; end

  STATES = %w[starting running paused complete cancelled]

  attribute :state,                               String
  attribute :total_products,                      Integer
  attribute :total_stores,                        Integer
  attribute :total_product_volume_in_millilitres, Integer
  attribute :total_product_price_in_cents,        Integer
  attribute :added_store_nos,                     Array
  attribute :removed_store_nos,                   Array
  attribute :added_product_nos,                   Array
  attribute :removed_product_nos,                 Array

  reference :last_event, CrawlEvent

  collection :events, CrawlEvent

  counter :total_jobs
  counter :total_finished_jobs

  set  :product_nos, CrawlItem
  set  :store_nos,   CrawlItem
  list :jobs,        CrawlItem

  index :state
  index :updated_at
  index :created_at

  def self.validate_states!(*states)
    states.each do |state|
      unless STATES.include?(state.to_s)
        raise ArgumentError, "Unknown state: #{state.inspect}"
      end
    end
  end

  def self.is(*states)
    validate_states!(*states)
    find(:state => states.map(&:to_s))
  end

  def self.any_active?
    is(:starting, :running, :paused).first ? true : false
  end

  def self.init
    raise StateError, 'Crawl is already running' if any_active?
    crawl = create(
      :state => 'starting',
      :total_products => 0,
      :total_stores => 0,
      :total_product_volume_in_millilitres => 0,
      :total_product_price_in_cents => 0)
    crawl
  end

  def is?(*states)
    self.class.validate_states!(*states)
    states.map(&:to_s).include?(self.state)
  end

  def is_locked?
    is? :complete, :cancelled
  end

  def is_active?
    is? :starting, :running, :paused
  end

  def has_jobs?
    jobs.count > 0
  end

  def progress
    if total_jobs == 0 || total_finished_jobs == 0
      0.0
    else
      total_finished_jobs.to_f / total_jobs.to_f
    end
  end

  def transition_to(new_state)
    self.class.validate_states!(new_state)
    case
    when is?(:complete)
      raise StateError, "Crawl is complete and can not be set to: #{new_state}"
    when is?(:cancelled)
      raise StateError, "Crawl is cancelled and can not be set to: #{new_state}"
    when new_state.to_s == 'running' && is?(:running)
      raise StateError, 'Crawl is running and can not be set to: running'
    when new_state.to_s == 'running' && !has_jobs?
      raise StateError, 'Crawl has no jobs and can not be set to: running'
    when new_state.to_s == 'paused'  && is?(:starting)
      raise StateError, 'Crawl is starting and can not be set to: paused'
    when new_state.to_s == 'paused'  && is?(:paused)
      raise StateError, 'Crawl is paused and can not be set to: paused'
    else
      self.state = new_state.to_s
      save
    end
  end

  def push_jobs(type, values)
    values.each { |val| pushjob(type, val) }
  end

  def pushjob(type, no)
    verify_unlocked!
    job = CrawlItem.create(:type => type.to_s, :no => no.to_i)
    if job.valid?
      jobs << job
      incr :total_jobs, 1
    end
    job
  end

  def log(message, level = :info, payload = {})
    verify_unlocked!
    ev = CrawlEvent.create(
      :crawl_id => self.id,
      :message => message,
      :level => level.to_s,
      :payload => payload)
    events << ev
    self.last_event = ev
    self.updated_at = Time.now.utc
    save
  end

  def validate
    super
    assert_member :state, STATES
  end

  def verify_unlocked!
    raise StateError, "Crawl is #{state}" if is_locked?
  end

end
