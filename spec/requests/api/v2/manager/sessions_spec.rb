require 'rails_helper'

RSpec.describe 'v2/manager/sessions API' do
  before do
    request.headers['Accept'] = 'application/vnd.lcboapi.v2+json'
  end

  it 'returns an auth token with correct credentials for validated user' do
    u = create_validated_user!

    post '/manager/sessions', session: { email: u.email, password: 'password' }
  end

  it 'returns errors with correct credentials for an invalidated user' do
    u = create_user!
    post '/manager/sessions', session: { email: u.email, password: 'password' }
  end

  it 'returns errors with incorrect credentials' do
  end

  it 'updates a session token expiry for an existing session' do
  end

  it 'fails to update with an invalid token' do
  end

  it 'returns the current session with an active auth token' do
  end

  it 'fails to return the current session with an inactive auth token' do
  end
end