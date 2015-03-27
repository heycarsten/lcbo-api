module V1
  module QueryHelper
    class InventoryFinder < Finder
      attr_accessor :store_id, :product_id

      def initialize(request, params)
        super

        self.store_id = params[:store_id]

        if (pid = params[:product_id]).present?
          self.product_id = ProductFinder.get(pid).try(:id)
        end
      end

      def self.get(product_id, store_id)
        Inventory.where(product_id: QueryHelper.find(:product, product_id).id, store_id: store_id).first
      end

      def as_args
        [product_id, store_id]
      end
    end
  end
end
