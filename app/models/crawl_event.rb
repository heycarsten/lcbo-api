class CrawlEvent < Ohm::Model

  include Ohm::Typecast
  include Ohm::Timestamping
  include Ohm::Rails

  attribute :level,   String
  attribute :message, String
  attribute :payload, Hash

  reference :crawl, Crawl

end
