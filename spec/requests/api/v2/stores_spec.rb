require 'rails_helper'

RSpec.describe 'V2 Stores API' do
  def prepare!
    @user           = create_verified_user!
    @private_key    = @user.keys.create!(label: 'Example', kind: :private_server)
    @public_key     = @user.keys.create!(label: 'Example', kind: Key.kinds[:web_client], domain: 'lcboapi.test')
    @public_key_dev = @user.keys.create!(label: 'Example', kind: Key.kinds[:web_client], domain: 'lcboapi.test', in_devmode: true)
    @stores = [
      Fabricate(:store, id: 4, name: 'Store B', inventory_count: 10),
      Fabricate(:store, id: 3, name: 'Store C', inventory_count: 20),
      Fabricate(:store, id: 2, name: 'Store A', inventory_count: 30),
      Fabricate(:store, id: 1, name: 'Store D', is_dead: true)
    ]

    @products = [
      Fabricate(:product, id: 1),
      Fabricate(:product, id: 2)
    ]

    @inventories = [
      Fabricate(:inventory, store_id: @stores[0].id, product_id: @products[0].id, quantity: 5),
      Fabricate(:inventory, store_id: @stores[1].id, product_id: @products[0].id, quantity: 10),
      Fabricate(:inventory, store_id: @stores[1].id, product_id: @products[1].id, quantity: 15)
    ]
  end

  describe 'JSONP and CORS' do
    it 'allows JSONP for public keys' do
      prepare!
      api_get "/stores?access_key=#{@public_key}&callback=jsonpcb"
      expect(response.body).to start_with '/**/jsonpcb({'
    end

    it 'disables JSONP for private keys' do
      prepare!
      api_get "/stores?access_key=#{@private_key}&callback=jsonpcb"
      expect(response.body).to_not start_with '/**/jsonpcb({'
    end

    it 'disables CORS for private keys' do
      prepare!
      api_headers['Authorization'] = "Token #{@private_key}"
      api_get '/stores'
      expect(response.headers['Access-Control-Allow-Origin']).to eq nil
    end

    it 'enables CORS for public keys' do
      prepare!
      api_headers['Origin'] = 'null'
      api_headers['Authorization'] = "Token #{@public_key}"
      api_get '/stores'
      expect(response.headers['Access-Control-Allow-Origin']).to eq '*'
    end

    it 'enforces origin for public keys with domains' do
      prepare!
      api_headers['Origin'] = nil
      api_headers['Authorization'] = "Token #{@public_key}"
      api_get '/stores'
      expect(response.status).to eq 403
      expect(json[:errors][0][:code]).to eq 'bad_origin'
    end

    it 'allows requests for public keys with domains' do
      prepare!
      api_headers['Origin'] = 'http://lcboapi.test'
      api_headers['Authorization'] = "Token #{@public_key}"
      api_get '/stores'
      expect(response.status).to eq 200
      expect(json[:data].size).to_not eq 0
    end
  end

  describe 'rate limiting' do
    it 'limits unique IP addresses per web client key when key is in devmode' do
      prepare!
      api_headers['Origin'] = 'http://lcboapi.test'
      api_headers['Authorization'] = "Token #{@public_key_dev}"

      api_headers['REMOTE_ADDR'] = '1.0.0.1'
      api_get '/stores'
      expect(response.status).to eq 200
      expect(response.headers['X-Client-Limit-Max']).to eq 3
      expect(response.headers['X-Client-Limit-Count']).to eq 1
      expect(response.headers['X-Client-Limit-TTL']).to be_present
      expect(response.headers['X-Rate-Limit-Count']).to be nil

      api_headers['REMOTE_ADDR'] = '1.0.0.2'
      api_get '/stores'
      expect(response.status).to eq 200
      expect(response.headers['X-Client-Limit-Count']).to eq 2

      api_headers['REMOTE_ADDR'] = '1.0.0.3'
      api_get '/stores'
      expect(response.status).to eq 200
      expect(response.headers['X-Client-Limit-Count']).to eq 3

      api_headers['REMOTE_ADDR'] = '1.0.0.1'
      api_get '/stores'
      expect(response.status).to eq 200
      expect(response.headers['X-Client-Limit-Count']).to eq 3

      api_headers['REMOTE_ADDR'] = '1.0.0.4'
      api_get '/stores'
      expect(response.status).to eq 403
      expect(response.headers['X-Client-Limit-Count']).to eq 4
      expect(json[:errors][0][:code]).to eq 'too_many_sessions'
    end
  end

  it 'requires authentication' do
    api_get '/stores/1'
    expect(response.status).to eq 401

    api_get '/stores'
    expect(response.status).to eq 401
  end

  it 'returns all stores with Authorization: Token' do
    prepare!
    api_headers['Authorization'] = "Token #{@private_key}"

    api_get '/stores'

    expect(response.status).to eq 200
    expect(json[:data].size).to eq 3
    expect(json[:meta][:pagination][:total_records]).to eq 3
  end

  it 'returns all stores with Authorization: Basic' do
    prepare!

    api_headers['Authorization'] = ActionController::HttpAuthentication::Basic.encode_credentials('x-access-key', @private_key)

    api_get '/stores'

    expect(response.status).to eq 200
    expect(json[:data].size).to eq 3
    expect(json[:meta][:pagination][:total_records]).to eq 3
  end

  it 'returns stores by an array of ids (index)' do
    prepare!
    api_headers['Authorization'] = "Token #{@private_key}"

    api_get "/stores/#{@stores[0].id},#{@stores[1].id}"

    expect(response.status).to eq 200
    expect(json[:data].size).to eq 2
    expect(json[:data].map { |s| s[:id] }).to include @stores[0].id.to_s, @stores[1].id.to_s
    expect(json[:meta]).to eq nil
  end

  it 'returns stores by id (show)' do
    prepare!
    api_headers['Authorization'] = "Token #{@private_key}"

    api_get "/stores/#{@stores[2].id}"

    expect(response.status).to eq 200
    expect(json[:data][:id]).to eq @stores[2].id.to_s
    expect(json[:meta]).to eq nil
  end

  it 'fails to return stores by id and query' do
    prepare!
    api_headers['Authorization'] = "Token #{@private_key}"

    api_get "/stores?id=1&q=fail"

    expect(response.status).to eq 400
    expect(json[:errors][0][:code]).to eq 'bad_param'
  end

  it 'returns stores by query' do
    prepare!
    api_headers['Authorization'] = "Token #{@private_key}"

    api_get '/stores?q=store+b'

    expect(response.status).to eq 200
    expect(json[:data].size).to eq 1
  end

  it 'returns stores by lat/lon' do
    prepare!
    api_headers['Authorization'] = "Token #{@private_key}"

    api_get "/stores?lat=#{@stores[2].latitude}&lon=#{@stores[2].longitude}"

    expect(response.status).to eq 200
    expect(json[:data].size).to eq 3
    expect(json[:data][0][:distance_in_meters]).to be 0
  end

  it 'can include dead stores' do
    prepare!
    api_headers['Authorization'] = "Token #{@private_key}"

    api_get "/stores?include_dead=yes"

    expect(response.status).to eq 200
    expect(json[:data].size).to eq 4
  end

  it 'can order results' do
    prepare!
    api_headers['Authorization'] = "Token #{@private_key}"

    api_get "/stores?sort=-id"

    expect(response.status).to eq 200
    expect(json[:data].size).to eq 3
    expect(json[:data][0][:id]).to eq '4'
    expect(json[:data][1][:id]).to eq '3'
    expect(json[:data][2][:id]).to eq '2'
  end

  it 'can constrain results' do
    prepare!
    api_headers['Authorization'] = "Token #{@private_key}"

    api_get "/stores?inventory_count_gt=10"

    expect(response.status).to eq 200
    expect(json[:data].size).to eq 2
    expect(json[:data].map { |s| s[:id] }).to include '3', '2'
  end

  it 'returns stores that have a product' do
    prepare!
    api_headers['Authorization'] = "Token #{@private_key}"

    api_get "/stores?product=#{@products[0].id}"

    linked_products    = json[:linked].select { |l| l[:type] == 'product' }
    linked_inventories = json[:linked].select { |l| l[:type] == 'inventory' }

    expect(response.status).to eq 200
    expect(linked_products[0][:id]).to eq @products[0].id.to_s
    expect(json[:data].size).to eq 2
    expect(json[:data][0][:id]).to eq @stores[0].id.to_s
    expect(json[:data][0][:links][:inventory]).to eq @inventories[0].compound_id
    expect(linked_inventories.size).to eq 2
    expect(linked_inventories[0][:id]).to eq @inventories[0].compound_id
  end

  it 'returns stores that have all products (many)' do
    prepare!

    api_headers['Authorization'] = "Token #{@private_key}"

    api_get "/stores?products=#{@products[0].id},#{@products[1].id}"
    expect(json[:data].size).to eq 1
  end

  it 'returns stores that have all products (one)' do
    prepare!

    api_headers['Authorization'] = "Token #{@private_key}"

    api_get "/stores?products=#{@products[0].id}"
    expect(json[:data].size).to eq 2
  end

  it 'returns stores that have a product' do
    prepare!

    api_headers['Authorization'] = "Token #{@private_key}"

    api_get "/stores?product=#{@products[0].id}"
    expect(json[:data].size).to eq 2
  end
end
