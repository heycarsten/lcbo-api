class Crawl < Ohm::Model

  include Ohm::Typecast
  include Ohm::Timestamping

  STATES = [
    :running, # Crawl is running stuff is happening.
    :paused,  # Crawl was paused due to an exception or user intervention.
    :finished # Crawl is complete.
  ]

  attribute :state,                               Symbol
  attribute :total_products,                      Integer
  attribute :total_stores,                        Integer
  attribute :total_product_volume_in_millilitres, Integer
  attribute :total_product_price_in_cents,        Integer

  list :events,             CrawlEvent
  list :product_nos_queue,  Integer
  list :store_nos_queue,    Integer

  def is_paused?
    :paused == state
  end

  def is_running?
    :running == state
  end

  def is_finished?
    :finished == state
  end

  def emit
    case
    when product_nos_queue.count != 0
      [:product, product_nos_queue.pop]
    when store_nos_queue.count != 0
      [:store, store_nos_queue.pop]
    else
      nil
    end
  end

  def validate
    assert_member :state, STATES
  end

end
