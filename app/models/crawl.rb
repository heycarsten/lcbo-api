class Crawl < Ohm::Model

  include Ohm::Typecast
  include Ohm::Timestamping

  class IncompleteCrawlError < StandardError; end
  class InsufficientJobsError < StandardError; end

  STATES = %w[
    starting  # Crawl is being initialized
    running   # Crawl is running, stuff is happening
    paused    # Crawl was paused due to an exception or user intervention
    finished  # Crawl is complete
    cancelled # Crawl was cancelled
  ]

  attribute :state,                               String
  attribute :total_products,                      Integer
  attribute :total_stores,                        Integer
  attribute :total_product_volume_in_millilitres, Integer
  attribute :total_product_price_in_cents,        Integer

  counter :total_jobs
  counter :total_finished_jobs

  list :jobs, CrawlJob

  index :state

  def self.all_finished?
    incomplete.count > 0
  end

  def self.incomplete
    find(:state => %w[starting running paused])
  end

  def self.cancelled
    find(:state => 'cancelled')
  end

  def self.finished
    find(:state => 'finished')
  end

  def self.init
    raise IncompleteCrawlError, 'already crawling' unless all_finished?
    crawl = create(
      :state => 'starting',
      :total_products => 0,
      :total_stores => 0,
      :total_product_volume_in_millilitres => 0,
      :total_product_price_in_cents => 0,
      :total_jobs => 0)
    crawl
  end

  def is_resumable?
    state == 'paused'
  end

  def cancel!
    set_state :cancelled
  end

  def start!
    raise CancelledCrawlError, 'crawl was cancelled' if 'cancelled' == state
    raise InsufficientJobsError, 'need at least one job' unless jobs.count > 0
    set_state :running
  end

  def store_nos=(values)
    values.each { |no| pushjob(:store, no) }
  end

  def product_nos=(values)
    values.each { |no| pushjob(:product, no) }
  end

  def set_state(state)
    self.state = state.to_s
    save
  end

  def pushjob(type, no)
    raise CancelledCrawlError, 'crawl was cancelled' if 'cancelled' == state
    job = CrawlJob.create(:type => type.to_s, :no => no.to_i)
    if job.valid?
      jobs << job
      incr :total_jobs, 1
    end
    job
  end

  def popjob(&block)
    raise CancelledCrawlError, 'crawl was cancelled' if 'cancelled' == state
    raise ArgumentError, 'block expected' unless block_given?
    while (state == 'running' && job = jobs.pop)
      begin
        yield job.type, job.no, job
        incr :total_finished_jobs, 1
      rescue => error
        log 'Pausing crawl', :warn
        set_state :paused
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
    CrawlEvent.create(
      :message => message,
      :level => level.to_s,
      :payload => payload.merge(:crawl_id => self.id))
  end

  def is_starting?
    'starting' == state
  end

  def is_paused?
    'paused' == state
  end

  def is_running?
    'running' == state
  end

  def is_finished?
    'finished' == state
  end

  def validate
    assert_member :state, STATES
  end

end
