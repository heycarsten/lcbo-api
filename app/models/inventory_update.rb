class InventoryUpdate < Ohm::Model

  include Ohm::Typecast

  attribute :crawl_timestamp, Integer

  attribute :quantity,        Integer
  attribute :updated_on,      String
  attribute :is_active,       Boolean

  reference :inventory, Inventory

end
