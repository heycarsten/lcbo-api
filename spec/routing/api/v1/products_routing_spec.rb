require 'rails_helper'

RSpec.describe 'V1 Product resources routing', type: :routing do
  it 'routes /products' do
    expect(get '/products').to route_to(
      controller: 'api/v1/products',
      action:     'index')
  end

  it 'routes /products/:id' do
    expect(get '/products/18').to route_to(
      controller: 'api/v1/products',
      action:     'show',
      id:         '18')
  end

  it 'routes /stores/:store_id/products' do
    expect(get '/stores/511/products').to route_to(
      controller: 'api/v1/products',
      action:     'index',
      store_id:   '511')
  end
end
