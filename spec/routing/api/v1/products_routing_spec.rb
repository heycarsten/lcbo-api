require 'spec_helper'

describe 'V1 Product resources routing' do
  it 'routes /products' do
    expect(get '/products').to route_to(
      controller: 'api/v1/products',
      action:     'index',
      version:    2)
  end

  it 'routes /products/:id' do
    expect(get '/products/18').to route_to(
      controller: 'api/v1/products',
      action:     'show',
      id:         '18',
      version:    2)
  end

  it 'routes /stores/:store_id/products' do
    expect(get '/stores/511/products').to route_to(
      controller: 'api/v1/products',
      action:     'index',
      store_id:   '511',
      version:    2)
  end
end
