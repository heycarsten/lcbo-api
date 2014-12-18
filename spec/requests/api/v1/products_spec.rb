require 'rails_helper'

RSpec.describe 'Products API (V1)', type: :request do
  before do
    @product1 = Fabricate(:product, id: '1')
    @product2 = Fabricate(:product, id: '2', name: 'Fitzgibbons')
    @product3 = Fabricate(:product, id: '3', name: 'B\'ock hop bob-omb')
    @product4 = Fabricate(:product, id: '4', name: 'I AM DEAD', is_dead: true)
    @store1   = Fabricate(:store, id: '1')
    @inv1     = Fabricate(:inventory, store: @store1, product: @product1)

    Fuzz.recache
  end

  it 'contains sane objects' do
    expect(Product.count).to eq 4
    expect(Store.count).to eq 1
    expect(Inventory.count).to eq 1
  end

  describe 'all products' do
    subject { '/products' }
    it_behaves_like 'a resource', size: 3
  end

  describe 'selective filtering' do
    before { get '/products?where=is_dead' }

    it 'returns only applicable products' do
      expect(response.json[:result].size).to eq 1
    end
  end

  describe 'rejective filtering' do
    before { get '/products?where_not=is_dead' }

    it 'returns only applicable products' do
      expect(response.json[:result].size).to eq 3
    end
  end

  describe 'full text search with match' do
    subject { '/products?q=fitzgibbons' }
    it_behaves_like 'a resource', size: 1
  end

  describe 'full text search with match (JSON)' do
    before { get '/products?q=fitzgibbons' }

    it 'contains a matched product' do
      expect(response.json[:result].size).to eq 1
      expect(response.json[:result][0]).to be_a Hash
      expect(response.json[:result][0][:name]).to eq 'Fitzgibbons'
      expect(response.json[:result][0][:id]).to eq @product2.id
    end

    it 'does not contain a suggestion' do
      expect(response.json[:suggestion]).to be_nil
    end
  end

  describe 'full text search with spaces' do
    before do
      get '/products?q=fitz+gibbons'
    end

    it 'does not contain a product resource' do
      expect(response.json[:result]).to be_a Array
      expect(response.json[:result].size).to be_zero
    end

    it 'contains a suggestion' do
      expect(response.json[:suggestion]).to eq 'fitzgibbons'
    end
  end

  describe 'full text search with slab quotes' do
    before do
      get '/products?q=B%27ock'
    end

    it 'does contain a product' do
      expect(response.json[:result].size).to eq 1
      expect(response.json[:result].first[:id]).to eq 3
    end
  end

  describe 'full text search with dashes' do
    before do
      get '/products?q=bob-omb'
    end

    it 'does contain a product' do
      expect(response.json[:result].size).to eq 1
      expect(response.json[:result].first[:id]).to eq 3
    end
  end

  describe 'full text search with crazy characters' do
    before do
      get '/products?q=Holy%21+Swee333t+Explo%24io%21%21%23%24%23%24n'
    end

    it 'returns json' do
      expect(response.json[:result]).to be_a Array
    end
  end

  describe 'full text search without match (JSON)' do
    before do
      get '/products?q=fitzgibins'
    end

    it 'does not contain a product resource' do
      expect(response.json[:result]).to be_a Array
      expect(response.json[:result].size).to be_zero
    end

    it 'contains a suggestion' do
      expect(response.json[:suggestion]).to eq 'fitzgibbons'
    end
  end

  describe 'get product' do
    subject { "/products/#{@product1.id}" }
    it_behaves_like 'a resource'
  end

  describe 'get product (not found)' do
    before { get '/products/9999999'}
    it_behaves_like 'a JSON 404 error'
  end
end
