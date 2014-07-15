require 'rails_helper'

RSpec.describe 'V2 Manager Sessions API' do
  it 'returns an auth token with correct credentials for verified user' do
    u = create_verified_user!
    api_post '/manager/sessions', session: {
      email: u.email,
      password: 'password'
    }
    expect(response).to be_invalid
    expect(json).to have_key :errors
  end

  it 'returns errors with correct credentials for an unverifed user' do
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