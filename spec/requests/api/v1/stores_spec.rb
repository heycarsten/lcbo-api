require 'spec_helper'

describe 'Stores API (V1)' do
  before do
    @store1   = Fabricate(:store)
    @store2   = Fabricate(:store, name: 'Test Store')
    @product1 = Fabricate(:product)
    @inv1     = Fabricate(:inventory, store: @store1, product: @product1)
  end

  describe 'all stores' do
    subject { '/stores' }
    it_behaves_like 'a resource', size: 2
  end

  context 'full text search with match (JSON)' do
    before { get '/stores?q=test' }

    it 'performs a full-text search' do
      expect(response.json[:result].size).to eq 1
      expect(response.json[:result][0][:id]).to eq @store2.id
    end
  end

  context 'ordering by distance_in_meters when not a geospatial search' do
    before { get '/stores?order=distance_in_meters' }

    it_behaves_like 'a JSON 400 error'

    it 'indicates that sorting by distance without geometry is impossible' do
      expect(response.json[:message]).to include('to order by distance_in_meters')
    end
  end

  context 'ordering by distance_in_meters with a geospatial search' do
    before { get "/stores?lat=#{@store1.latitude}&lon=#{@store1.longitude}&order=distance_in_meters.desc" }

    it 'performs a spatial search' do
      expect(response.json[:message]).to eq nil
      expect(response.json[:result].size).to eq 2
      expect(response.json[:result][0][:distance_in_meters]).to eq 0
    end
  end

  context '/stores (with spatial search)' do
    before { get "/stores?lat=#{@store1.latitude}&lon=#{@store1.longitude}" }

    it 'performs a spatial search' do
      expect(response.json[:result].size).to eq 2
      expect(response.json[:result][0][:distance_in_meters]).to eq 0
    end
  end

  context '/stores (with invalid spatial query)' do
    before { get "/stores?lat=43.0" }

    it_behaves_like 'a JSON 400 error'

    it 'contains the error type' do
      expect(response.json[:error]).to eq 'bad_query_error'
    end
  end

  describe 'show store' do
    subject { "/stores/#{@store1.id}" }
    it_behaves_like 'a resource'
  end

  describe 'stores with product' do
    subject { "/products/#{@product1.id}/stores" }
    it_behaves_like 'a resource', size: 1
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
      expect(response.json[:result].size).to eq 1
      expect(response.json[:result][0][:distance_in_meters]).to eq 0
    end
  end

  context 'stores with product (product not found)' do
    before { get '/products/1/stores' }
    it_behaves_like 'a JSON 404 error'
  end

  context '/products/:id/stores' do
    before { get "/products/#{@product1.id}/stores" }

    it 'is properly formed' do
      expect(response.json[:result]).to be_a Array
      expect(response.json[:result][0]).to be_a Hash
    end

    it 'contains pager metadata in the response' do
      expect(response.json[:pager]).to be_a Hash
    end

    it 'contains quantity in the store resource' do
      expect(response.json[:result][0][:quantity]).to eq @inv1.quantity
    end

    it 'contains product resource in the response' do
      expect(response.json[:product]).to be_a Hash
    end

    it 'contains updated_on in the store resource' do
      expect(response.json[:result][0][:updated_on]).to eq @inv1.reported_on.iso8601
    end
  end
end
