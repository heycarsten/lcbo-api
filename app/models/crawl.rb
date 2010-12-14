class Crawl < Sequel::Model

  class StateError < StandardError; end

  plugin :redis
  plugin :timestamps, :update_on_create => true

  list :store_nos,           Integer
  list :product_nos,         Integer
  list :added_store_nos,     Integer
  list :removed_store_nos,   Integer
  list :added_product_nos,   Integer
  list :removed_product_nos, Integer
  list :update_jobs
  list :commit_jobs

  many_to_one :crawl_event
  one_to_many :crawl_events

  def self.latest
    order(:id.desc).first
  end

  def self.is(*states)
    filter(:state => states.map(&:to_s))
  end

  def self.any_active?
    !is(nil, :running, :paused).empty?
  end

  def self.init
    raise 'Crawl is already running' if any_active?
    create
  end

  def is?(*states)
    states.map(&:to_s).include?(self.state)
  end

  def is_locked?
    is? :finished, :cancelled
  end

  def is_active?
    is? nil, :running, :paused
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

  def push_jobs(type, ids)
    ids.each { |id| addjob(type, id) }
    save
  end

  def addjob(type, id)
    verify_unlocked!
    jobs << "#{type}:#{id}"
    self.total_jobs += 1
  end

  def popjob
    (job = jobs.pop) && job.split(':')
  end

  def log(message, level = :info, payload = {})
    verify_unlocked!
    ce = add_crawl_event(
      :level => level.to_s,
      :message => message.to_s,
      :payload => JSON.dump(payload),
      :created_at => Time.now.utc)
    self.crawl_event_id = ce.id
    save
  end

  protected

  def verify_unlocked!
    raise StateError, "Crawl is #{state}" if is_locked?
  end

end

