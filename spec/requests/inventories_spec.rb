require 'spec_helper'

describe 'Inventory resources' do
  before :all do
    clean_database

    @product1 = Fabricate(:product)
    @product2 = Fabricate(:product)
    @product3 = Fabricate(:product)
    @store1   = Fabricate(:store)
    @store2   = Fabricate(:store)
    @store3   = Fabricate(:store)
    @inv1     = Fabricate(:inventory, :product => @product1, :store => @store1)
    @inv2     = Fabricate(:inventory, :product => @product1, :store => @store2)
    @inv3     = Fabricate(:inventory, :product => @product1, :store => @store3)
    @inv4     = Fabricate(:inventory, :product => @product2, :store => @store1)
    @inv5     = Fabricate(:inventory, :product => @product2, :store => @store2)
    @inv6     = Fabricate(:inventory, :product => @product2, :store => @store3)
    @inv7     = Fabricate(:inventory, :product => @product3, :store => @store1)
    @inv8     = Fabricate(:inventory, :product => @product3, :store => @store2)
    @inv9     = Fabricate(:inventory, :product => @product3, :store => @store3)
  end

  context '/inventories' do
    before do
      get '/inventories'
    end

    it_should_behave_like 'a JSON response'

    it 'should contain inventory resources' do
      response.json[:result].size.should == 9
    end
  end

  context '/products/:product_id/inventories' do
    before do
      get "/products/#{@product1.id}/inventories"
    end

    it_should_behave_like 'a JSON response'

    it 'should contain inventory resources' do
      response.json[:result].size.should == 3
    end
  end
end
