require 'spec_helper'

describe 'V1 Store resources routing' do
  it 'routes /stores' do
    expect(get '/stores').to route_to(
      controller: 'api/v1/stores',
      action:     'index',
      version:    2)
  end

  it 'routes /stores/:id' do
    expect(get '/stores/511').to route_to(
      controller: 'api/v1/stores',
      action:     'show',
      id:         '511',
      version:    2)
  end

  it 'routes /products/:product_id/stores' do
    expect(get '/products/18/stores').to route_to(
      controller: 'api/v1/stores',
      action:     'index',
      product_id: '18',
      version:    2)
  end
end
