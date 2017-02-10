require 'rails_helper'

RSpec.describe 'Datasets API (V1)', type: :request do
  def prepare!
    @user = create_verified_user!

    @server_key = @user.keys.create!(label: 'Example', kind: :private_server)
    @web_key    = @user.keys.create!(label: 'Example', kind: :web_client, domain: 'lcboapi.test')
    @native_key = @user.keys.create!(label: 'Example', kind: :native_client)

    @crawls = [
      Fabricate(:crawl),
      Fabricate(:crawl),
      Fabricate(:crawl, state: 'cancelled')
    ]
  end

  it 'responds with many datasets' do
    prepare!

    get '/datasets'

    expect(response).to be_success
    expect(response).to be_json
    expect(response.payload[:result].size).to eq 2
  end

  it 'responds with one dataset' do
    prepare!

    get "/datasets/#{@crawls[0].id}"

    expect(response).to be_success
    expect(response).to be_json
    expect(response.payload[:result][:id]).to eq @crawls[0].id
  end

  it 'responds with one dataset (Authenticated)' do
    prepare!

    get '/datasets', headers: { 'Authorization' => "Token #{@server_key}" }

    expect(response).to be_success
    expect(response).to be_json
    expect(response.payload[:result].size).to eq 2

    total = @server_key.cycle_requests.sum { |r| r[1] }

    expect(total).to eq 1
  end

  it 'disallows HTTPS for unauthenticated requests' do
    prepare!

    get '/datasets', headers: { 'X-Forwarded-Proto' => 'https' }

    expect(response.status).to eq 401
    expect(response.payload[:error]).to eq 'unauthorized'
  end

  it 'disallows CORS for unauthenticated requests' do
    prepare!

    get '/datasets', headers: { 'Origin' => 'http://lcboapi.test' }

    expect(response.status).to eq 401
    expect(response.payload[:error]).to eq 'unauthorized'
  end

  it 'allows CORS for authenticated requests' do
    prepare!

    get '/datasets', headers: {
      'Origin'        => 'http://lcboapi.test',
      'Authorization' => "Token #{@web_key}"
    }

    expect(response.status).to eq 200
    expect(response.headers['Access-Control-Allow-Origin']).to eq '*'
  end
end
