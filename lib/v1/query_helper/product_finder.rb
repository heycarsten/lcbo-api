module V1
  module QueryHelper
    class ProductFinder < Finder
      attr_accessor :product_id

      def initialize(request, params)
        super
        self.product_id = (params[:id] || params[:product_id])
      end

      def self.get(raw_id)
        id = raw_id.to_i

        if id > 999999
          Product.where(upc: id).first
        else
          Product.where(id: id).first
        end
      end

      def as_args
        [product_id]
      end
    end
  end
end
