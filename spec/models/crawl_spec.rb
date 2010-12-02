# == Schema Information
#
# Table name: crawls
#
#  id                                            :integer         not null, primary key
#  crawl_event_id                                :integer
#  state                                         :string(255)
#  added_store_nos                               :text
#  removed_store_nos                             :text
#  added_product_nos                             :text
#  removed_product_nos                           :text
#  total_products                                :integer         default(0)
#  total_stores                                  :integer         default(0)
#  total_inventories                             :integer         default(0)
#  total_product_inventory_count                 :integer         default(0)
#  total_product_inventory_volume_in_milliliters :integer         default(0)
#  total_product_inventory_price_in_cents        :integer         default(0)
#  total_jobs                                    :integer         default(0)
#  total_finished_jobs                           :integer         default(0)
#  created_at                                    :datetime
#  updated_at                                    :datetime
#
# Indexes
#
#  index_crawls_on_created_at  (created_at)
#  index_crawls_on_state       (state)
#  index_crawls_on_updated_at  (updated_at)
#

require 'spec_helper'

describe Crawl do
  after :each do
    @crawl && @crawl.destroy
  end

  describe 'given there are no active crawls' do
    it 'should allow a new crawl to be initial  ized' do
      -> { Crawl.init }.should_not raise_error
    end
  end

  describe 'given there is an active crawl' do
    it 'should raise an error' do
      -> { Crawl.init; Crawl.init }.should raise_error(Crawl::AlreadyRunningError)
    end
  end
end

