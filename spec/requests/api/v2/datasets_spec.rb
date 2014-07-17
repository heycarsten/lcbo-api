require 'rails_helper'

RSpec.describe 'V2 Manager Datasets API' do
  describe 'GET /datasets' do
    def generate_data!
      @user   = create_verified_user!
      @key    = @user.keys.create!
      @crawls = [
        Fabricate(:crawl),
        Fabricate(:crawl),
        Fabricate(:crawl, state: 'cancelled')
      ]
    end

    it 'returns datasets when provided an API Key via param' do
      generate_data!

      api_get '/datasets', api_key: @key

      expect(response.status).to eq 200
      expect(json.keys).to include :meta, :datasets
      expect(json[:datasets].size).to eq 2
      expect(json[:datasets][0][:links][:products]).to be_blank
      expect(json[:datasets][0][:links][:stores]).to be_blank
    end

    it 'returns datasets when provided an API Key via header' do
      generate_data!

      api_headers['X-API-Key'] = @key
      api_get '/datasets'

      expect(response.status).to eq 200
      expect(json.keys).to include :meta, :datasets
    end

    it 'returns datasets when provided an Auth Token' do
      generate_data!

      api_headers['X-Auth-Token'] = @user.auth_token
      api_get '/datasets'

      expect(response.status).to eq 200
      expect(json.keys).to include :meta, :datasets
    end

    it 'fails with no token' do
      api_get '/datasets'

      expect(response.status).to eq 401
      expect(json[:error]).to be_present
      expect(json[:error][:detail]).to be_present
    end
  end

  describe 'GET /datasets/:id' do
    
  end
end
