require 'spec_helper'

describe 'Inventory resources routing' do
  it 'routes /inventories' do
    expect(get '/inventories').to route_to(
      controller: 'inventories',
      action:     'index',
      version:    2)
  end

  it 'routes /products/:products_id/inventories' do
    expect(get '/products/18/inventories').to route_to(
      controller: 'inventories',
      action:     'index',
      product_id: '18',
      version:    2)
  end

  it '/stores/:store_id/products/:products_id/inventory' do
    expect(get '/stores/511/products/18/inventory').to route_to(
      controller: 'inventories',
      action:     'show',
      store_id:   '511',
      product_id: '18',
      version:    2)
  end
end
