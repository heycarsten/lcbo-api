require 'spec_helper'

describe Crawl do
  describe 'with nil store_nos and product_nos' do
    before do
      @crawl = Fabricate(:crawl, :product_ids => nil, :store_ids => nil)
    end

    it 'should exist' do
      @crawl.should be_persisted
    end

    it 'should be serializable' do
      @crawl.as_json[:product_ids].should == []
    end
  end
end
