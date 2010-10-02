require 'spec_helper'

describe Product do

  describe '#commit' do
    before :all do
      @product = Factory(:product)
      @product.commit(
        :was_discontinued => false,
        :price_in_cents => 1700,
        :regular_price_in_cents => 1800,
        :limited_time_offer_savings_in_cents => 100,
        :limited_time_offer_ends_on => '2010-10-10',
        :bonus_reward_miles => nil,
        :bonus_reward_miles_ends_on => nil)
    end

  end

end
