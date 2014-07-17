require 'rails_helper'

RSpec.describe 'V2 Manager Passwords API' do
  describe 'POST /manager/passwords' do
    it 'sends an email with change password link for email of verified user' do
      u = create_verified_user!

      api_post '/manager/passwords', email: u.email

      expect(response.status).to eq 204
      expect(last_delivery.to.first).to eq u.email
      expect(last_delivery.subject).to match /password/i
    end

    it 'fails to send message to email that does not exist' do
      api_post '/manager/passwords', email: 'herp@example.com'

      expect(response.status).to eq 422
      expect(has_errors_for(:email)).to eq true
    end

    it 'fails to send message to unverified email' do
      u = create_user!

      api_post '/manager/passwords', email: u.new_email.address

      expect(response.status).to eq 422
      expect(has_errors_for(:email)).to eq true
    end
  end

  describe 'PUT /manager/passwords/:token' do
    it 'returns a session for a valid password token' do
      u = create_verified_user!
      t = u.verification_token

      api_put "/manager/passwords/#{t}", password: '1234abcd'

      u.reload

      expect(response.status).to eq 200
      expect(u.password_digest).to eq '1234abcd'
      expect(json[:session][:token]).to be_present

      api_put "/manager/passwords/#{t}", password: 'failpass'

      expect(response.status).to eq 404
    end

    it 'fails for an invalid token' do
      t = Token.generate(:verification)

      api_put "/manager/passwords/#{t}"

      expect(response.status).to eq 404
      expect(json[:error][:detail]).to be_present
    end

    it 'fails for an invalid password' do
      u = create_verified_user!
      t = u.verification_token

      api_put "/manager/passwords/#{t}", password: '2short'

      expect(response.status).to eq 422
      expect(json[:errors][0][:path]).to eq 'password'
    end
  end
end