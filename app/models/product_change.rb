class ProductChange

  include Mongoid::Document

  field :price_in_cents,                  :type => Integer
  field :inventory_count,                 :type => Integer
  field :inventory_volume_in_milliliters, :type => Integer

  belongs_to_related :crawl

  embedded_in :product, :inverse_of => :changes

end
