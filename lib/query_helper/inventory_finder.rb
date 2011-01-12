module QueryHelper
  class InventoryFinder < Finder

    attr_accessor :store_id, :product_id

    def initialize(request, params)
      super
      self.store_id   = params[:store_id]
      self.product_id = params[:product_id]
    end

    def self.get(product_id, store_id)
      Inventory[product_id, store_id]
    end

    def as_args
      [product_id, store_id]
    end

  end
end
