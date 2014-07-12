module LCBO
  class StoreIdsParser < Parser
    field :ids do
      root.xpath('//stores//store//locationNumber').map { |n| n.content.to_i }
    end
  end
end
