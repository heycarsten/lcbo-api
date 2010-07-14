class CrawlTask

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :state
  field :finished_at,     :type => DateTime
  field :did_finish,      :type => Boolean
  field :error_class
  field :error_message
  field :error_backtrace

  embedded_in :crawl, :inverse_of => :tasks

end
