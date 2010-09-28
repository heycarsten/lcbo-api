class CrawlLog < Ohm::Model

  include Ohm::Timestamping

  attribute :job
  attribute :message
  attribute :error_class
  attribute :error_message
  attribute :error_backtrace

end
