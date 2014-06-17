class Crawl < ActiveRecord::Base
  include RedisAbuse::Model

  class StateError < StandardError; end

  SERIALIZED_FIELDS = [
    :store_ids,
    :product_ids,
    :added_product_ids,
    :added_store_ids,
    :removed_product_ids,
    :removed_store_ids]
  list :crawled_store_ids,   :integer
  list :crawled_product_ids, :integer
  list :jobs


  SERIALIZED_FIELDS.each do |f|
    serialize(f)
  end

  scope :is, ->(*states) { where(state: states.map(&:to_s)) }

  belongs_to :crawl_event
  has_many :crawl_events

  def self.latest
    order(id: :desc).first
  end

  def self.any_active?
    is(nil, :running, :paused).count != 0
  end

  def self.init
    raise 'Crawl is already running' if any_active?
    create
  end

  def previous
    @previous ||= begin
      Crawl.
        order(id: :desc).
        where.not(id: id).
        where(state: 'finished').
        first
    end
  end

  def product_ids
    super || []
  end

  def store_ids
    super || []
  end

  def diff!
    self.store_ids   = crawled_store_ids.all
    self.product_ids = crawled_product_ids.all

    if previous
      self.added_product_ids   = (product_ids - previous.product_ids)
      self.removed_product_ids = (previous.product_ids - product_ids)
      self.added_store_ids     = (store_ids - previous.store_ids)
      self.removed_store_ids   = (previous.store_ids - store_ids)
    else
      self.added_product_ids   = []
      self.removed_product_ids = []
      self.added_store_ids     = []
      self.removed_store_ids   = []
    end

    save
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

    ce = crawl_event.create(
      level:      level.to_s,
      message:    message.to_s,
      payload:    JSON.dump(payload),
      created_at: Time.now.utc)

    self.crawl_event_id = ce.id

    save
  end

  protected

  def verify_unlocked!
    raise StateError, "Crawl is #{state}" if is_locked?
  end
end
