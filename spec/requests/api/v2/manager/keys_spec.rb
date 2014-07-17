require 'rails_helper'

RSpec.describe 'V2 Manager Keys API' do
  describe 'GET /manager/keys' do
    it 'lists all keys for the authenticated user' do
      log_in_user(u = create_verified_user!)

      records = [
        create_key!(user: u),
        create_key!(user: u),
        create_key!(user: u)
      ]

      api_get '/manager/keys'

      expect(keys = json[:keys]).to be_a Array

      key = keys.first

      expect(response.status).to eq 200
      expect(keys.size).to eq 3

      expect(key).to have_key :label
      expect(key).to have_key :info
      expect(key).to have_key :token
      expect(key).to have_key :created_at
      expect(key).to have_key :updated_at
    end
  end
end
