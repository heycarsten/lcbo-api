require 'spec_helper'

describe 'Store resources' do
  before :all do
    clean_database

    @store1   = Fabricate(:store)
    @store2   = Fabricate(:store, :name => 'Test Store')
    @product1 = Fabricate(:product)
    @inv1     = Fabricate(:inventory, :store => @store1, :product => @product1)
  end

  context '/stores' do
    before do
      get '/stores'
    end

    it_should_behave_like 'a JSON response'
  end

  context '/stores (with full-text search)' do
    before do
      get '/stores?q=test'
    end

    it_should_behave_like 'a JSON response'

    it 'performs a full-text search' do
      response.json[:result].size == 1
      response.json[:result][0][:id].should == @store2.id
    end
  end

  context '/stores (with spatial search)' do
    before do
      get "/stores?lat=#{@store1.latitude}&lon=#{@store1.longitude}"
    end

    it_should_behave_like 'a JSON response'

    it 'performs a spatial search' do
      response.json[:result].size == 2
      response.json[:result][0][:distance_in_meters].should == 0
    end
  end

  context '/stores (with invalid spatial query)' do
    before do
      get "/stores?lat=43.0"
    end

    it_should_behave_like 'a JSON 400 error'

    it 'contains the error type' do
      response.json[:error].should == 'bad_query_error'
    end
  end

  context '/stores/:id' do
    before do
      get "/stores/#{@store1.id}"
    end

    it_should_behave_like 'a JSON response'
  end

  context '/stores/:id (not found)' do
    before do
      get "/stores/0"
    end
    
    it_should_behave_like 'a JSON 404 error'
  end

  context '/products/:id/stores (with spatial search)' do
    before do
      get "/products/#{@product1.id}/stores?lat=#{@store1.latitude}" \
          "&lon=#{@store1.longitude}"
    end

    it_should_behave_like 'a JSON response'

    it 'performs a spatial search' do
      response.json[:result].size == 2
      response.json[:result][0][:distance_in_meters].should == 0
    end
  end

  context '/products/:id/stores' do
    before do
      get "/products/#{@product1.id}/stores"
    end

    it_should_behave_like 'a JSON response'

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