class Inventory < Ohm::Model

  include Ohm::Typecast
  include Ohm::Archive

  attribute :is_hidden,   Boolean
  attribute :crawled_at,  Time

  attribute :product_no,  Integer
  attribute :store_no,    Integer
  attribute :quantity,    Integer
  attribute :updated_on,  String

  index :product_no
  index :store_no
  index :is_hidden

  archive :updated_on, [:quantity]

end
