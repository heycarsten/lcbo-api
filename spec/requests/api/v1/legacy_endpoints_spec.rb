require 'rails_helper'

RSpec.describe 'Legacy (V1) API endpoints', type: :request do
  let!(:product) { Fabricate(:product) }
  let!(:store) { Fabricate(:store, latitude: 43.0, longitude: -78.0) }
  let!(:inv) { Fabricate(:inventory, product: product, store: store, quantity: 5) }

  it 'routes /products/search' do
    get '/products/search'
    expect(response.json[:result].size).to eq 1
  end

  it 'routes /stores/search' do
    get '/stores/search'
    expect(response.json[:result].size).to eq 1
  end

  it 'routes /stores/:store_id/products/search' do
    get "/stores/#{store.id}/products/search"
    expect(response.json[:result].size).to eq 1
  end

  it 'routes /products/:product_id/inventory' do
    get "/products/#{product.id}/inventory"
    expect(response.json[:result].size).to eq 1
  end

  it 'routes /stores/:store_id/products/:product_id/inventory' do
    get "/stores/#{store.id}/products/#{product.id}/inventory"
    expect(response.json[:result][:product_id]).to eq product.id
  end

  it 'routes /stores/near/:latitude/:longitude' do
    get '/stores/near/43.0/-78.0'
    expect(response.json[:result].size).to eq 1
  end

  it 'routes /stores/near/:latitude/:longitude/with/:product_id' do
    get "/stores/near/43.0/-78.0/with/#{product.id}"
    expect(response.json[:result].size).to eq 1
  end
end
