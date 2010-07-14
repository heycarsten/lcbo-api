class InventoryChange

  include Mongoid::Document

  field :quantity,    :type => Integer
  field :updated_on,  :type => Date

  belongs_to_related :crawl

  embedded_in :inventory, :inverse_of => :changes

end
