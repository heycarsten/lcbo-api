class InventoryCrawl

  include Mongoid::Document

  field :crawl_timestamp, :type => Integer
  field :quantity,        :type => Integer
  field :updated_on,      :type => DateTime

  embedded_in :inventory, :inverse_of => :changes

end
