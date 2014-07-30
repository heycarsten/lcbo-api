require 'rails_helper'

RSpec.describe 'V2 Products API' do
  def prepare!
    @user    = create_verified_user!
    @key     = @user.keys.create!
    @products = [
      Fabricate(:product, id: 4, name: 'Product B', inventory_count: 10),
      Fabricate(:product, id: 3, name: 'Product C', inventory_count: 20),
      Fabricate(:product, id: 2, name: 'Product A', inventory_count: 30),
      Fabricate(:product, id: 1, name: 'Product D', is_dead: true)
    ]
    api_headers['X-API-Key'] = @key
  end
