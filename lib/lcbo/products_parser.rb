module LCBO
  class ProductsParser < Parser
    field :products do
      root.xpath('//products//product').map do |node|
        parse_product_node(node)
      end
    end

    def parse_product_node(node)
      id        = node.css('itemNumber')[0].content.to_i
      air_miles = node.css('airMiles')[0]['bonusMiles'].to_i
      price     = (node.css('price')[0].content.sub('$ ', '').to_f * 100).to_i

      regular_price = if (reg = node.css('limitedTimeOffer')[0]['regularPrice'])
        (reg.to_f * 100).to_i
      else
        price
      end

      savings = (regular_price - price)

      { id:                                  id,
        price_in_cents:                      price,
        regular_price_in_cents:              regular_price,
        limited_time_offer_savings_in_cents: savings,
        has_limited_time_offer:              savings != 0,
        bonus_reward_miles:                  air_miles,
        has_bonus_reward_miles:              air_miles != 0 }
    end
  end
end
