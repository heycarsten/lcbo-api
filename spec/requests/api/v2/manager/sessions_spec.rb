require 'rails_helper'

RSpec.describe 'V2 Manager Sessions API' do
  describe 'POST /manager/sessions' do
    it 'returns an auth token with correct credentials for verified user' do
      u = create_verified_user!

      api_post '/manager/sessions', session: {
        email: u.email,
        password: 'password'
      }

      expect(response.status).to eq 200
      expect(json[:session][:token]).to be_a String
      expect(json[:session][:expires_at]).to be_a String
    end

    it 'returns errors with correct credentials for an unverifed user' do
      u = create_user!

      api_post '/manager/sessions', session: {
        email: u.email,
        password: 'password'
      }

      expect(response.status).to eq 422
      expect(json[:errors][:base][0]).to be_a String
    end

    it 'returns errors with incorrect credentials' do
      u = create_verified_user!
      api_post '/manager/sessions', session: {
        email: u.email,
        password: 'fail'
      }

      expect(response.status).to eq 422
    end
  end

  describe 'PUT /manager/session' do
    it 'updates a session token expiry for an existing session' do
      log_in_user(u = create_verified_user!)
      api_put '/manager/session'
      expect(response.status).to eq 200
      expires = Time.parse(json[:session][:expires_at])
      now     = Time.now
      ttl     = (expires - now).round
      expect(ttl).to be >= User::SESSION_TTL
    end

    it 'fails to update with an invalid token' do
      
    end
  end

  describe 'GET /manager/session' do
    it 'returns the current session with an active auth token' do

    end

    it 'fails to return the current session with an inactive auth token' do
    end
  end
end