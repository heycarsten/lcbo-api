require 'spec_helper'

describe 'Revisions resources' do
  before :all do
    clean_database

    @product = Fabricate(:product)
    @store = Fabricate(:store)
    @inv = Fabricate(:inventory, :store_id => @store.id, :product_id => @product.id)

    3.times { RevisionFactory(:product, @product) }
    4.times { RevisionFactory(:store, @store) }
    5.times { |i| RevisionFactory(:inventory, @inv, :updated_on => Date.new(2010, 10, i+1)) }
  end

  context '/products/:product_id/history' do
    before do
      get "/products/#{@product.id}/history"
    end

    it_should_behave_like 'a JSON response'

    it 'returns revisions' do
      response.json[:result].should be_a Array
      response.json[:result].size.should == 3
    end
  end

  context '/stores/:store_id/history' do
    before do
      get "/stores/#{@store.id}/history"
    end

    it_should_behave_like 'a JSON response'

    it 'returns revisions' do
      response.json[:result].should be_a Array
      response.json[:result].size.should == 4
    end
  end

  context '/stores/:store_id/products/:product_id/history' do
    before do
      get "/stores/#{@inv.store_id}/products/#{@inv.product_id}/history"
    end

    it_should_behave_like 'a JSON response'

    it 'returns revisions' do
      response.json[:result].should be_a Array
      response.json[:result].size.should == 5
    end
  end
end
