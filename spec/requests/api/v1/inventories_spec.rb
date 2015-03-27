require 'rails_helper'

RSpec.describe 'Inventories API (V1)', type: :request do
  before do
    @products = [
      Fabricate(:product),
      Fabricate(:product, upc: 100000000),
      Fabricate(:product)
    ]

    @stores = [
      Fabricate(:store),
      Fabricate(:store),
      Fabricate(:store)
    ]

    @inventories = [
      Fabricate(:inventory, product: @products[0], store: @stores[0], quantity: 5),
      Fabricate(:inventory, product: @products[0], store: @stores[1], quantity: 10),
      Fabricate(:inventory, product: @products[0], store: @stores[2], quantity: 15),
      Fabricate(:inventory, product: @products[1], store: @stores[0], quantity: 20),
      Fabricate(:inventory, product: @products[1], store: @stores[1], quantity: 25),
      Fabricate(:inventory, product: @products[1], store: @stores[2], quantity: 30),
      Fabricate(:inventory, product: @products[2], store: @stores[0], quantity: 35),
      Fabricate(:inventory, product: @products[2], store: @stores[1], quantity: 40),
      Fabricate(:inventory, product: @products[2], store: @stores[2], quantity: 45)
    ]
  end

  describe 'all inventories' do
    subject { '/inventories' }
    it_behaves_like 'a resource', size: 9
  end

  describe 'all inventories for a product' do
    subject { "/products/#{@products[0].id}/inventories" }
    it_behaves_like 'a resource', size: 3
  end

  it 'looks up inventories by product UPC if the given account supports it' do
    user = create_verified_user!
    user.plan.update!(has_upc_lookup: true)
    key = user.keys.create!(label: 'Example', kind: :private_server)

    get "/products/100000000/inventories?access_key=#{key}"

    expect(response.status).to eq 200
    expect(response.json[:result].size).to eq 3
    expect(response.json[:product][:id]).to eq @products[1].id
  end
end
