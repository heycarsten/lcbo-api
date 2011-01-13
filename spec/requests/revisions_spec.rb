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

  describe 'product revisions' do
    subject { "/products/#{@product.id}/history" }
    it_behaves_like 'a resource', :size => 3
  end

  describe 'store revisions' do
    subject { "/stores/#{@store.id}/history" }
    it_behaves_like 'a resource', :size => 4
  end

  describe 'inventory revisions' do
    subject { "/stores/#{@inv.store_id}/products/#{@inv.product_id}/history" }
    it_behaves_like 'a resource', :size => 5
  end
end
