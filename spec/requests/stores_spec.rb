require 'spec_helper'

describe 'Store resources' do
  before :all do
    clean_database

    @store1   = Fabricate(:store)
    @store2   = Fabricate(:store, :name => 'Test Store')
    @product1 = Fabricate(:product)
    @inv1     = Fabricate(:inventory, :store => @store1, :product => @product1)
  end

  describe 'all stores' do
    subject { '/stores' }
    it_behaves_like 'a resource', :size => 2
  end

  context 'full text search with match (JSON)' do
    before { get '/stores?q=test' }

    it 'performs a full-text search' do
      response.json[:result].size == 1
      response.json[:result][0][:id].should == @store2.id
    end
  end

  context 'ordering by distance_in_meters when not a geospatial search' do
    before { get '/stores?order=distance_in_meters' }

    it_behaves_like 'a JSON 400 error'

    it 'indicates that sorting by distance without geometry is impossible' do
      response.json[:message].should include 'to order by distance_in_meters'
    end
  end

  context 'ordering by distance_in_meters with a geospatial search' do
    before { get "/stores?lat=#{@store1.latitude}&lon=#{@store1.longitude}&order=distance_in_meters.desc" }

    it 'performs a spatial search' do
      response.json[:message].should be_nil
      response.json[:result].size == 2
      response.json[:result][0][:distance_in_meters].should == 0
    end
  end

  context '/stores (with spatial search)' do
    before { get "/stores?lat=#{@store1.latitude}&lon=#{@store1.longitude}" }

    it 'performs a spatial search' do
      response.json[:result].size == 2
      response.json[:result][0][:distance_in_meters].should == 0
    end
  end

  context '/stores (with invalid spatial query)' do
    before { get "/stores?lat=43.0" }

    it_behaves_like 'a JSON 400 error'

    it 'contains the error type' do
      response.json[:error].should == 'bad_query_error'
    end
  end

  describe 'show store' do
    subject { "/stores/#{@store1.id}" }
    it_behaves_like 'a resource'
  end

  describe 'stores with product' do
    subject { "/products/#{@product1.id}/stores" }
    it_behaves_like 'a resource', :size => 1
  end

  context 'show store (not found)' do
    before { get "/stores/1" }
    it_behaves_like 'a JSON 404 error'
  end

  context 'stores with product and spatial search' do
    before do
      get "/products/#{@product1.id}/stores?lat=#{@store1.latitude}" \
          "&lon=#{@store1.longitude}"
    end

    it 'performs a spatial search' do
      response.json[:result].size == 2
      response.json[:result][0][:distance_in_meters].should == 0
    end
  end

  context 'stores with product (product not found)' do
    before { get '/products/1/stores' }
    it_behaves_like 'a JSON 404 error'
  end

  context '/products/:id/stores' do
    before { get "/products/#{@product1.id}/stores" }

    it 'is properly formed' do
      response.json[:result].should be_a Array
      response.json[:result][0].should be_a Hash
    end

    it 'contains pager metadata in the response' do
      response.json[:pager].should be_a Hash
    end

    it 'contains quantity in the store resource' do
      response.json[:result][0][:quantity].should == @inv1.quantity
    end

    it 'contains product resource in the response' do
      response.json[:product].should be_a Hash
    end

    it 'contains updated_on in the store resource' do
      response.json[:result][0][:updated_on].should == @inv1.updated_on.to_s
    end
  end
end
