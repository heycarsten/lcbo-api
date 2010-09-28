class Inventory < Ohm::Model

  include Ohm::Typecast

  attribute :is_hidden,       Boolean
  attribute :crawl_timestamp, Integer

  attribute :product_no,      Integer
  attribute :store_no,        Integer
  attribute :quantity,        Integer
  attribute :updated_on,      Time

  index :product_no
  index :store_no
  index :is_hidden

  list :updates, InventoryUpdate

end
