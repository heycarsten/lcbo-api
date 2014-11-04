require 'rails_helper'

RSpec.describe 'V2 Manager Sessions API' do
  describe 'GET /manager/session' do
    it 'returns the current session with an active auth token' do
      log_in_user(u = create_verified_user!)
      api_get '/manager/session'
      expect(response.status).to eq 200
      expect(json[:session][:token]).to be_a String
      expires = Time.parse(json[:session][:expires_at])
      now     = Time.now
      expect(expires).to be > now
    end

    it 'fails to return the current session with an inactive auth token' do
      api_headers['Authorization'] = 'Token ' + Token.generate(:session, user_id: 'herp').to_s
      api_get '/manager/session'
      expect(response.status).to eq 401
    end
  end

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
      expect(json[:error][:detail]).to_not be_empty
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
      expect(json[:session][:token]).to be_a String
      expires = Time.parse(json[:session][:expires_at])
      now     = Time.now
      ttl     = (expires - now).round
      expect(ttl).to be >= User::SESSION_TTL
    end

    it 'fails to update with an invalid token' do
      api_headers['Authorization'] = 'Token ' + Token.generate(:session, user_id: 'herp').to_s
      api_put '/manager/session'
      expect(response.status).to eq 401
    end
  end

  describe 'DELETE /manager/session' do
    it 'destroys the session token when given a valid token' do
      log_in_user(u = create_verified_user!)
      token = api_headers['Authorization']
      expect(User.lookup(token)).to be_a User

      api_delete '/manager/session'
      expect(response.status).to eq 204
      expect(User.lookup(token)).to be_nil

      api_headers['Authorization'] = token
      api_delete '/manager/session'
      expect(response.status).to eq 401
    end
  end
end
