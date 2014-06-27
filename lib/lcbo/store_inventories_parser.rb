module LCBO
  class StoreInventoriesParser < Parser
    def before_parse
      return if root.xpath('//product').length > 0
      raise LCBO::NotFoundError, "no inventory data was returned"
    end

    field :inventories do
      root.xpath('//products//product').map do |node|
        { product_id: node.xpath('itemNumber').first.content.to_i,
          quantity:   node.xpath('productQuantity').first.content.to_i }
      end
    end
  end
end
