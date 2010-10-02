class InventoryUpdate < Ohm::Model

  include Ohm::Typecast

  attribute :crawled_at,      Time
  attribute :quantity,        Integer
  attribute :updated_on,      String
  attribute :is_active,       Boolean

end
