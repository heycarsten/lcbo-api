module QueryHelper
  class ProductFinder < Finder
    attr_accessor :product_id

    def initialize(request, params)
      super
      self.product_id = (params[:id] || params[:product_id])
    end

    def self.get(id)
      Product.where(id: id).first
    end

    def as_args
      [product_id]
    end
  end
end
