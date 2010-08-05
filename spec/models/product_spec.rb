require 'spec_helper'

describe Product do
  context 'with many updates' do
    before :all do
      @product = Product.create(:product_no => 1, :crawl_timestamp => 1, :name => 'Test', :price_in_cents => 10)
      @product.update_attributes(:product_no => 1, :crawl_timestamp => 2, :name => 'Test', :price_in_cents => 10)
      @product.update_attributes(:product_no => 1, :crawl_timestamp => 3, :name => 'Test', :price_in_cents => 8)
    end

    it 'should have three versions' do
      @product.version.should == 3
    end
  end
end
