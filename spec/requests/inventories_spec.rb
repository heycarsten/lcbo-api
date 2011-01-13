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

  describe 'all inventories' do
    subject { '/inventories' }
    it_behaves_like 'a resource', :size => 9
  end

  describe 'all inventories for a product' do
    subject { "/products/#{@product1.id}/inventories" }
    it_behaves_like 'a resource', :size => 3
  end
end
