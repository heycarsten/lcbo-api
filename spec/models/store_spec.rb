require 'spec_helper'

describe Store, 'creation' do

  context 'when commiting a store does not exist' do
    before :all do
      @crawl = Fabricate(:crawl)
      @store = Store.commit(@crawl, STORES[444])
    end

    it 'should persist the store' do
      @store.persisted?.should be_true
    end
  end

  context 'when commiting to an existing store' do
    before :all do
      @crawl = Fabricate(:crawl)
      Store.commit(@crawl, STORES[444])
      Store.commit(@crawl, :store_no => 444, :products_count => 100)
      Store.commit(@crawl, :store_no => 444, :inventory_count => 100)
    end

    it 'should add the changes to the existing store document' do
      Store.where(:store_no => 444).count.should == 1
    end

    it 'should only have two updates' do
      Store.where(:store_no => 444).first.updates.size.should == 2
    end
  end

end
