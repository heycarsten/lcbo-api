module LCBO
  class ProductIdsParser < Parser
    field :ids do
      root.xpath('//products//product//itemNumber').map { |n| n.content.to_i }
    end
  end
end
