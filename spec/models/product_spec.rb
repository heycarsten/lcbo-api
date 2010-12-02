# == Schema Information
#
# Table name: products
#
#  id                                  :integer         not null, primary key
#  crawl_id                            :integer
#  is_hidden                           :boolean         default(FALSE)
#  name                                :string(100)
#  is_discontinued                     :boolean         default(FALSE)
#  price_in_cents                      :integer         default(0)
#  regular_price_in_cents              :integer         default(0)
#  limited_time_offer_savings_in_cents :integer         default(0)
#  limited_time_offer_ends_on          :string(10)
#  bonus_reward_miles                  :integer         default(0)
#  bonus_reward_miles_ends_on          :string(10)
#  stock_type                          :string(10)
#  primary_category                    :string(32)
#  secondary_category                  :string(32)
#  origin                              :string(60)
#  package                             :string(32)
#  package_unit_type                   :string(20)
#  package_unit_volume_in_milliliters  :integer         default(0)
#  total_package_units                 :integer         default(0)
#  total_package_volume_in_milliliters :integer         default(0)
#  volume_in_milliliters               :integer         default(0)
#  alcohol_content                     :integer         default(0)
#  price_per_liter_of_alcohol_in_cents :integer         default(0)
#  price_per_liter_in_cents            :integer         default(0)
#  inventory_count                     :integer         default(0)
#  inventory_volume_in_milliliters     :integer         default(0)
#  inventory_price_in_cents            :integer         default(0)
#  sugar_content                       :string(3)
#  producer_name                       :string(80)
#  released_on                         :string(10)
#  has_limited_time_offer              :boolean         default(FALSE)
#  has_bonus_reward_miles              :boolean         default(FALSE)
#  is_seasonal                         :boolean         default(FALSE)
#  is_vqa                              :boolean         default(FALSE)
#  description                         :text
#  serving_suggestion                  :text
#  tasting_note                        :text
#  created_at                          :datetime
#  updated_at                          :datetime
#
# Indexes
#
#  index_products_on_crawl_id         (crawl_id)
#  index_products_on_inventory_count  (inventory_count)
#  index_products_on_is_discontinued  (is_discontinued)
#  index_products_on_updated_at       (updated_at)
#

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

