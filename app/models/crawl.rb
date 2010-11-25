class Crawl < Ohm::Model

  include Ohm::Typecast
  include Ohm::Timestamping
  include Ohm::ExtraValidations

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

  counter :total_jobs
  counter :total_finished_jobs

  set  :product_nos, CrawlItem
  set  :store_nos,   CrawlItem
  list :jobs,        CrawlItem

  index :state

  def self.validate_states!(*states)
    states.each do |state|
      unless STATES.include?(state.to_s)
        raise ArgumentError, "Unknown state: #{state.inspect}"
      end
    end
  end

  def self.is(*states)
    validate_states!(*states)
    find(:state => values.map(&:to_s))
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

  def transition(new_state)
    self.class.validate_states!(new_state)
    case
    when is?(:complete)
      raise StateError, "Crawl is complete and can not be set to: #{state}"
    when is?(:cancelled)
      raise StateError, "Crawl is cancelled and can not be set to: #{state}"
    when state.to_s == 'running' && is?(:running)
      raise StateError, 'Crawl is running and can not be set to: running'
    when state.to_s == 'running' && jobs.count == 0
      raise StateError, 'Crawl has no jobs and can not be set to: running'
    when state.to_s == 'paused'  && is?(:starting)
      raise StateError, 'Crawl is starting and can not be set to: paused'
    when state.to_s == 'paused'  && is?(:paused)
      raise StateError, 'Crawl is paused and can not be set to: paused'
    else
      self.state = state.to_s
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

  def popjob(&block)
    verify_unlocked!
    while (is?(:running) && job = jobs.pop)
      begin
        yield(job)
        incr :total_finished_jobs, 1
      rescue => error
        log 'Pausing crawl', :warn
        transition_to :paused
        jobs << job
        log 'An error occurred', :error,
          :job_type => job.type,
          :job_no => job.no,
          :error_class => error.class,
          :error_message => error.message,
          :error_backtrace => error.backtrace.join("\n")
      end
    end
  end

  def log(message, level = :info, payload = {})
    verify_unlocked!
    CrawlEvent.create(
      :message => message,
      :level => level.to_s,
      :payload => payload.merge(:crawl_id => self.id))
  end

  def validate
    super
    assert_member :state, STATES
  end

  def verify_unlocked!
    raise StateError, "Crawl is #{state}" if is_locked?
  end

end
