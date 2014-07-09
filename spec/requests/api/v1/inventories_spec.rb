require 'rails_helper'

RSpec.describe 'Inventories API (V1)', type: :request do
  before do
    @products = [
      Fabricate(:product),
      Fabricate(:product),
      Fabricate(:product)
    ]

    @stores = [
      Fabricate(:store),
      Fabricate(:store),
      Fabricate(:store)
    ]

    @inventories = [
      Fabricate(:inventory, product: @products[0], store: @stores[0]),
      Fabricate(:inventory, product: @products[0], store: @stores[1]),
      Fabricate(:inventory, product: @products[0], store: @stores[2]),
      Fabricate(:inventory, product: @products[1], store: @stores[0]),
      Fabricate(:inventory, product: @products[1], store: @stores[1]),
      Fabricate(:inventory, product: @products[1], store: @stores[2]),
      Fabricate(:inventory, product: @products[2], store: @stores[0]),
      Fabricate(:inventory, product: @products[2], store: @stores[1]),
      Fabricate(:inventory, product: @products[2], store: @stores[2])
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
end
