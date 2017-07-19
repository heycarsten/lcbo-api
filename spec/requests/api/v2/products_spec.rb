require 'rails_helper'

RSpec.describe 'V2 Products API' do
  def prepare!
    @user    = create_verified_user!
    @key     = @user.keys.create!(label: 'Example App', kind: :private_server)
    @products = [
      Fabricate(:product, id: 4, name: 'Product B', inventory_count: 10),
      Fabricate(:product, id: 3, name: 'Product C', inventory_count: 20),
      Fabricate(:product, id: 2, name: 'Product A', inventory_count: 30),
      Fabricate(:product, id: 1, name: 'Product D', is_dead: true)
    ]
    api_headers['Authorization'] = "Token #{@key}"
  end

  it 'returns a product' do
    prepare!
    api_get '/v2/products/4'

    expect(response.status).to eq 200
    expect(json[:data][:id]).to eq @products[0].id.to_s
    expect(json[:data][:type]).to eq 'products'
    expect(json[:meta]).to eq nil
  end
end
