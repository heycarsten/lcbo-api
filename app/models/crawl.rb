class Crawl < ActiveRecord::Base

  class StateError < StandardError; end

  STATES = %w[starting running paused complete cancelled]

  serialize :store_nos,           Array
  serialize :product_nos,         Array
  serialize :added_store_nos,     Array
  serialize :removed_store_nos,   Array
  serialize :added_product_nos,   Array
  serialize :removed_product_nos, Array

  belongs_to :crawl_event

  has_many :crawl_events

  validates_inclusion_of :state, :in => STATES

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
    store_nos << no
    save
  end

  def remove_store_no(no)
    store_nos.delete(no)
    save
  end

  def add_product_no(no)
    product_nos << no
    save
  end

  def remove_product_no(no)
    product_nos.delete(no)
    save
  end

  def push_jobs(type, ids)
    ids.each { |id| addjob(type, id) }
  end

  def addjob(type, id)
    verify_unlocked!
    listadd :jobs, "#{type}:#{id}"
    increment :total_jobs
  end

  def popjob
    (job = listpop(:jobs)) && job.split(':')
  end

  def joblen
    listlen :jobs
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

  def listrem(list, value)
    RDB.lrem(key(list), 0, value)
  end

  def listget(list, start = 0, finish = -1)
    RDB.lrange(key(list), start, finish)
  end

  def listadd(list, value)
    RDB.rpush(key(list), value)
  end

  def listpop(list)
    RDB.rpop(key(list))
  end

  def listlen(list)
    RDB.llen(key(list))
  end

  def key(postfix = nil)
    a = ["Crawl:#{id}"]
    a << postfix.to_s if postfix
    a.join(':')
  end

  def verify_unlocked!
    raise StateError, "Crawl is #{state}" if is_locked?
  end

end
