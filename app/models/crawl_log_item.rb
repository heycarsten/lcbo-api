class CrawlLogItem

  include Mongoid::Document
  include Mongoid::Timestamps

  field :job
  field :message
  field :error_class
  field :error_message
  field :error_backtrace

  embedded_in :crawl, :inverse_of => :log_items

  scope :latest, order_by(:created_at.desc)

end
