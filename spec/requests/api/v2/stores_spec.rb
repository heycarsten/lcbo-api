require 'rails_helper'

RSpec.describe 'V2 Stores API' do
  def prepare!
    @user        = create_verified_user!
    @private_key = @user.keys.create!
    @public_key  = @user.keys.create!(is_public: true, domain: 'lcboapi.test')
    @stores = [
      Fabricate(:store, id: 4, name: 'Store B', inventory_count: 10),
      Fabricate(:store, id: 3, name: 'Store C', inventory_count: 20),
      Fabricate(:store, id: 2, name: 'Store A', inventory_count: 30),
      Fabricate(:store, id: 1, name: 'Store D', is_dead: true)
    ]
  end

  describe 'JSONP and CORS' do
    it 'allows JSONP for public keys' do
      prepare!
      api_get "/stores?api_key=#{@public_key}&callback=jsonpcb"
      expect(response.body).to start_with 'jsonpcb({'
    end

    it 'disables JSONP for private keys' do
      prepare!
      api_get "/stores?api_key=#{@private_key}&callback=jsonpcb"
      expect(response.body).to_not start_with 'jsonpcb({'
    end

    it 'disables CORS for private keys' do
      prepare!
      api_headers['X-API-Key'] = @private_key
      api_get '/stores'
      expect(response.headers['Access-Control-Allow-Origin']).to eq nil
    end

    it 'enables CORS for public keys' do
      prepare!
      api_headers['Origin'] = 'null'
      api_headers['X-API-Key'] = @public_key
      api_get '/stores'
      expect(response.headers['Access-Control-Allow-Origin']).to eq '*'
    end
  end

  it 'requires authentication' do
    api_get '/stores/1'
    expect(response.status).to eq 401

    api_get '/stores'
    expect(response.status).to eq 401
  end

  it 'returns all stores' do
    prepare!
    api_headers['X-API-Key'] = @private_key

    api_get '/stores'

    expect(response.status).to eq 200
    expect(json[:stores].size).to eq 3
    expect(json[:meta][:pagination][:total_records]).to eq 3
  end

  it 'returns stores by an array of ids (index)' do
    prepare!
    api_headers['X-API-Key'] = @private_key

    api_get "/stores?id[]=#{@stores[0].id}&id[]=#{@stores[1].id}"

    expect(response.status).to eq 200
    expect(json[:stores].size).to eq 2
    expect(json[:stores].map { |s| s[:id] }).to include @stores[0].id, @stores[1].id
    expect(json[:meta]).to eq nil
  end

  it 'returns stores by id (show)' do
    prepare!
    api_headers['X-API-Key'] = @private_key

    api_get "/stores/#{@stores[2].id}"

    expect(response.status).to eq 200
    expect(json[:store][:id]).to eq @stores[2].id
    expect(json[:meta]).to eq nil
  end

  it 'fails to return stores by id and query' do
    prepare!
    api_headers['X-API-Key'] = @private_key

    api_get "/stores?id=1&q=fail"

    expect(response.status).to eq 400
    expect(json[:error][:code]).to eq 'bad_param'
  end

  it 'returns stores by query' do
    prepare!
    api_headers['X-API-Key'] = @private_key

    api_get '/stores?q=store+b'

    expect(response.status).to eq 200
    expect(json[:stores].size).to eq 1
  end

  it 'returns stores by lat/lon' do
    prepare!
    api_headers['X-API-Key'] = @private_key

    api_get "/stores?lat=#{@stores[2].latitude}&lon=#{@stores[2].longitude}"

    expect(response.status).to eq 200
    expect(json[:stores].size).to eq 3
    expect(json[:stores][0][:distance_in_meters]).to be 0
  end

  it 'can include dead stores' do
    prepare!
    api_headers['X-API-Key'] = @private_key

    api_get "/stores?include_dead=yes"

    expect(response.status).to eq 200
    expect(json[:stores].size).to eq 4
  end

  it 'can order results' do
    prepare!
    api_headers['X-API-Key'] = @private_key

    api_get "/stores?id_order=desc"

    expect(response.status).to eq 200
    expect(json[:stores].size).to eq 3
    expect(json[:stores][0][:id]).to eq 4
    expect(json[:stores][1][:id]).to eq 3
    expect(json[:stores][2][:id]).to eq 2
  end

  it 'can constrain results' do
    prepare!
    api_headers['X-API-Key'] = @private_key

    api_get "/stores?inventory_count_gt=10"

    expect(response.status).to eq 200
    expect(json[:stores].size).to eq 2
    expect(json[:stores].map { |s| s[:id] }).to include 3, 2
  end

  it 'returns stores that have a product' do
    prepare!
    api_headers['X-API-Key'] = @private_key

    product   = Fabricate(:product, id: 1)
    inventory = Fabricate(:inventory, store_id: @stores[1].id, product_id: product.id)

    api_get "/stores?product_id=1"

    expect(response.status).to eq 200
    expect(json[:product][:id]).to eq product.id
    expect(json[:stores].size).to eq 1
    expect(json[:stores][0][:id]).to eq @stores[1].id
    expect(json[:stores][0][:quantity]).to eq inventory.quantity
  end
end
