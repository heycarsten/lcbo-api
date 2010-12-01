class Crawl < ActiveRecord::Model

  class StateError < StandardError; end

  STATES = %w[starting running paused complete cancelled]

  serialize :added_store_nos,     Array
  serialize :removed_store_nos,   Array
  serialize :added_product_nos,   Array
  serialize :removed_product_nos, Array

  belongs_to :crawl_event

  has_many :crawl_events

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

  def push_jobs(type, ids)
    ids.each { |id| addjob(type, id) }
  end

  def addjob(type, id)
    verify_unlocked!
    listadd :jobs, "#{type}:#{id}"
    increment :total_jobs
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

  def validate
    super
    assert_member :state, STATES
  end

  def verify_unlocked!
    raise StateError, "Crawl is #{state}" if is_locked?
  end

end
