require 'rails_helper'

RSpec.describe 'V2 Stores API' do
  def generate_data!
    @user   = create_verified_user!
    @key    = @user.keys.create!
    @stores = [
      Fabricate(:store, name: 'Store B'),
      Fabricate(:store, name: 'Store C'),
      Fabricate(:store, name: 'Store A')
    ]
  end

  it 'GET /stores' do
    generate_data!

    api_get '/stores', api_key: @key

    expect(response.status).to eq 200
    expect(json[:stores].size).to eq 3
  end
end
