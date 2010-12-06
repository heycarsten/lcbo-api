class Crawl < Sequel::Model

  include Sequel::RedisHelper

  class StateError < StandardError; end

  STATES = %w[starting running paused complete cancelled]

  list :store_nos,           Integer
  list :product_nos,         Integer
  list :added_store_nos,     Integer
  list :removed_store_nos,   Integer
  list :added_product_nos,   Integer
  list :removed_product_nos, Integer
  list :jobs

  many_to_one :crawl_event
  one_to_many :crawl_events

  scope :is, lambda { |*states|
    validate_states!(*states)
    where :state => states.map(&:to_s)
  }

  def self.validate_states!(*states)
    states.each do |state|
      unless STATES.include?(state.to_s)
        raise ArgumentError, "Unknown state: #{state.inspect}"
      end
    end
  end

  def self.any_active?
    is(:starting, :running, :paused).exists?
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
    jobs.length > 0
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
    when new_state.to_s == 'complete' && has_jobs?
      raise StateError, 'Crawl is not done and can not be set to: complete'
    else
      self.state = new_state.to_s
      save
    end
  end

  def push_jobs(type, ids)
    ids.each { |id| addjob(type, id) }
  end

  def addjob(type, id)
    verify_unlocked!
    jobs << "#{type}:#{id}"
    increment :total_jobs
  end

  def popjob
    (job = jobs.pop) && job.split(':')
  end

  def log(message, level = :info, payload = {})
    verify_unlocked!
    ev = crawl_events.create(
      :crawl_id => self.id,
      :message => message,
      :level => level.to_s,
      :payload => payload)
    self.crawl_event = ev
    save
  end

  protected

  def validate
    super
    errors.add(:state, 'is unknown') unless STATES.include?(state)
  end

  def verify_unlocked!
    raise StateError, "Crawl is #{state}" if is_locked?
  end

end

