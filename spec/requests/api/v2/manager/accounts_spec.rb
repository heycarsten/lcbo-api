require 'rails_helper'

RSpec.describe 'V2 Manager Accounts API' do
  describe 'GET /manager/account' do
    it 'returns the account with a valid session token' do
      log_in_user(u = create_verified_user!)

      api_get '/manager/account'

      expect(response.status).to eq 200
      expect(json.keys).to include :account
      expect(json[:account].keys).to include :name, :email
    end

    it 'fails with an invalid session token' do
      api_headers['Authorization'] = 'Token ' + Token.generate(:session, user_id: 'herp').to_s
      api_get '/manager/account'

      expect(response.status).to eq 401
      expect(json[:error][:detail]).to be_a String
    end
  end

  describe 'POST /manager/accounts' do
    it 'returns errors if the email address has already been taken' do
      u = create_user!

      api_post '/manager/accounts', account: {
        name:     'Carsten',
        email:    u.new_email.address,
        password: 'password'
      }

      expect(response.status).to eq 422
      expect(has_errors_for(:email)).to eq true
    end

    it 'returns errors if the password is too short' do
      api_post '/manager/accounts', account: {
        name: 'Carsten',
        email: 'test@example.com',
        password: 'passwd'
      }

      expect(response.status).to eq 422
      expect(has_errors_for(:password)).to eq true
    end

    it 'returns a new unverified account' do
      api_post '/manager/accounts', account: {
        name: 'Carsten',
        email: 'carsten@example.com',
        password: 'password'
      }

      expect(response.status).to eq 201
      expect(json[:account][:email]).to be_blank
      expect(json[:account][:unverified_email]).to eq 'carsten@example.com'
      expect(ActionMailer::Base.deliveries.first.subject).to match /welcome/i
    end
  end

  describe 'PUT /manager/accounts' do
    it 'updates password when current password matches' do
      log_in_user(u = create_verified_user!)

      api_put '/manager/account', account: {
        new_password: 'password2',
        current_password: 'password'
      }

      u.reload

      expect(response.status).to eq 204
      expect(u.password_digest).to eq 'password2'
    end

    it 'fails to update password when current password is wrong' do
      log_in_user(u = create_verified_user!)

      api_put '/manager/account', account: {
        new_password: 'password2',
        current_password: 'herp'
      }

      expect(response.status).to eq 422
      expect(has_errors_for(:password)).to eq false
      expect(has_errors_for(:current_password)).to eq true
    end

    it 'fails to update password when new password is invalid' do
      log_in_user(u = create_verified_user!)

      api_put '/manager/account', account: {
        new_password: 'boop',
        current_password: 'password'
      }

      expect(response.status).to eq 422
      expect(has_errors_for(:password)).to eq false
      expect(has_errors_for(:current_password)).to eq false
      expect(has_errors_for(:new_password)).to eq true
    end

    it 'updates name' do
      log_in_user(u = create_verified_user!)

      api_put '/manager/account', account: {
        name: 'Yoyo Sup'
      }

      u.reload

      expect(response.status).to eq 204
      expect(u.name).to eq 'Yoyo Sup'
    end

    it 'fails to update name with invalid chars' do
      log_in_user(u = create_verified_user!)

      api_put '/manager/account', account: {
        name: "Yo\r\nLOL"
      }

      expect(response.status).to eq 422
      expect(has_errors_for(:name)).to eq true
    end
  end

  describe 'DELETE /manager/account' do
    it 'destroys the current account' do
      log_in_user(u = create_verified_user!)

      api_delete '/manager/account'

      expect(response.status).to eq 204
      expect(User.where(id: u.id).exists?).to eq false
    end
  end
end
