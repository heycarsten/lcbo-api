class Crawl < Ohm::Model

  include Ohm::Typecast
  include Ohm::Timestamping
  include Ohm::ExtraValidations
  include Ohm::Rails

  class StateError < StandardError; end

  STATES = %w[starting running paused complete cancelled]

  attribute :state,               String
  attribute :added_store_nos,     Array
  attribute :removed_store_nos,   Array
  attribute :added_product_nos,   Array
  attribute :removed_product_nos, Array

  reference :last_event, CrawlEvent

  collection :events, CrawlEvent

  counter :total_products
  counter :total_stores
  counter :total_inventories
  counter :total_product_inventory_count
  counter :total_product_inventory_volume_in_milliliters
  counter :total_product_inventory_price_in_cents
  counter :total_jobs
  counter :total_finished_jobs

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
    create(:state => 'starting')
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
    joblen > 0
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
    when new_state.to_s == 'paused' && is?(:starting)
      raise StateError, 'Crawl is starting and can not be set to: paused'
    when new_state.to_s == 'paused' && is?(:paused)
      raise StateError, 'Crawl is paused and can not be set to: paused'
    when new_state.to_s == 'complete' && is?(:paused)
      raise StateError, 'Crawl is paused and can not be set to: complete'
    when new_state.to_s == 'complete' && joblen != 0
      raise StateError, 'Crawl is not done and can not be set to: complete'
    else
      self.state = new_state.to_s
      save
    end
  end

  def add_store_no(no)
    listadd :store_nos, no
  end

  def remove_store_no(no)
    listrem :store_nos, no
  end

  def store_nos
    listget(:store_nos).map(&:to_i)
  end

  def add_product_no(no)
    listadd :product_nos, no
  end

  def remove_product_no(no)
    listrem :product_nos, no
  end

  def product_nos
    listget(:product_nos).map(&:to_i)
  end

  def push_jobs(type, ids)
    ids.each { |id| addjob(type, id) }
  end

  def addjob(type, id)
    verify_unlocked!
    listadd :jobs, "#{type}:#{id}"
    incr :total_jobs, 1
  end

  def popjob
    if (job = listpop(:jobs))
      job.split(':')
    else
      nil
    end
  end

  def joblen
    listlen :jobs
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

  protected

  def listrem(list, value)
    key[list].lrem(0, value)
  end

  def listget(list, start = 0, finish = -1)
    key[list].lrange(start, finish)
  end

  def listadd(list, value)
    key[list].rpush(value)
  end

  def listpop(list)
    key[list].rpop
  end

  def listlen(list)
    key[list].llen
  end

  def validate
    super
    assert_member :state, STATES
  end

  def verify_unlocked!
    raise StateError, "Crawl is #{state}" if is_locked?
  end

end
