require 'rails_helper'

RSpec.describe 'Products API (V1)', type: :request do
  before do
    @product1 = Fabricate(:product, id: 1)
    @product2 = Fabricate(:product, id: 2, name: 'Fitzgibbons')
    @product3 = Fabricate(:product, id: 3, name: 'B\'ock hop bob-omb')
    @product4 = Fabricate(:product, id: 4, name: 'I AM DEAD', is_dead: true)
    @store1   = Fabricate(:store, id: 1)
    @inv1     = Fabricate(:inventory, store: @store1, product: @product1)

    Fuzz.recache
  end

  it 'contains sane objects' do
    expect(Product.count).to eq 4
    expect(Store.count).to eq 1
    expect(Inventory.count).to eq 1
  end

  it 'returns an index of products' do
    get '/products'

    expect(response.status).to eq 200
    expect(response.json[:result].size).to eq 3
  end

  it 'filters results selectively' do
    get '/products?where=is_dead'
    expect(response.json[:result].size).to eq 1
  end

  it 'filters results exclusively' do
    get '/products?where_not=is_dead'
    expect(response.json[:result].size).to eq 3
  end

  it 'allows full text search with match (JSON)' do
    get '/products?q=fitzgibbons'

    expect(response.json[:result].size).to eq 1
    expect(response.json[:result][0]).to be_a Hash
    expect(response.json[:result][0][:name]).to eq 'Fitzgibbons'
    expect(response.json[:result][0][:id]).to eq @product2.id
    expect(response.json[:suggestion]).to be_nil
  end

  it 'allows full text search without matches' do
    get '/products?q=fitz+gibbons'

    expect(response.json[:result]).to be_a Array
    expect(response.json[:result].size).to be_zero
    expect(response.json[:suggestion]).to eq 'fitzgibbons'
  end

  it 'allows full text search with slab quotes' do
    get '/products?q=B%27ock'

    expect(response.json[:result].size).to eq 1
    expect(response.json[:result].first[:id]).to eq 3
  end

  it 'allows full text search with dashes' do
    get '/products?q=bob-omb'

    expect(response.json[:result].size).to eq 1
    expect(response.json[:result].first[:id]).to eq 3
  end

  it 'full text searches with crazy characters' do
    get '/products?q=Holy%21+Swee333t+Explo%24io%21%21%23%24%23%24n'

    expect(response.json[:result]).to be_a Array
  end

  it 'full text searches without match (JSON)' do
    get '/products?q=fitzgibins'

    expect(response.json[:result]).to be_a Array
    expect(response.json[:result].size).to be_zero
    expect(response.json[:suggestion]).to eq 'fitzgibbons'
  end

  it 'returns single resources' do
    get "/products/#{@product1.id}"
    expect(response.json[:result]).to be_a Hash
    expect(response.status).to eq 200
    expect(response.content_type).to be_json
  end

  it 'returns 404s when product does not exist' do
    get '/products/9999999'
    expect(response.json[:error]).to be_present
    expect(response.status).to eq 404
  end
end
