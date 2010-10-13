class CrawlEvent < Ohm::Model

  include Ohm::Timestamping
  include Ohm::Typecast

  attribute :level,   String
  attribute :message, String
  attribute :payload, Hash

end
