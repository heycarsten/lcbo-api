require 'rails_helper'

RSpec.describe 'V2 Manager Keys API' do
  describe 'GET /manager/keys' do
    it 'lists all keys for the authenticated user' do
      u1 = create_verified_user!
      u2 = create_verified_user!

      log_in_user(u1)

      records = [
        create_key!(user_id: u1.id),
        create_key!(user_id: u1.id),
        create_key!(user_id: u1.id),
        create_key!(user_id: u2.id)
      ]

      expect(u1.keys).to_not include records.last
      expect(u1.keys.count).to eq 3
      expect(u2.keys.count).to eq 1

      api_get '/manager/keys'

      keys = json[:keys]
      key  = keys.first

      expect(response.status).to eq 200
      expect(keys.size).to eq 3

      expect(key).to have_key :label
      expect(key).to have_key :info
      expect(key).to have_key :token
      expect(key).to have_key :created_at
      expect(key).to have_key :updated_at
    end

    it 'fails if not authenticated' do
      api_headers['Authorization'] = 'Token ' + Token.generate(:session, user_id: 'herp').to_s

      api_get '/manager/keys'

      expect(response.status).to eq 401
    end
  end

  describe 'GET /manager/keys/:id' do
    it 'returns the key owned by the authenticated user' do
      u1 = create_verified_user!
      u2 = create_verified_user!
      k1 = create_key!(user_id: u1)
      k2 = create_key!(user_id: u2)

      log_in_user(u1)

      api_get "/manager/keys/#{k1.id}"

      expect(response.status).to eq 200
      expect(json[:key][:token]).to be_present

      expect {
        api_get "/manager/keys/#{k2.id}"
      }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe 'POST /manager/keys' do
    it 'creates a new key for the authenticated user given valid attributes' do
      log_in_user(u = create_verified_user!)

      api_post '/manager/keys', key: {
        label: 'HERP',
        info: 'Yo Yo Yo',
        kind: 'private_server'
      }

      expect(response.status).to eq 201
      expect(u.keys.first.id).to eq json[:key][:id]
      expect(json[:key]).to be_present
      expect(json[:key][:token]).to be_present
      expect(json[:key][:label]).to eq 'HERP'
      expect(json[:key][:info]).to eq 'Yo Yo Yo'
      expect(json[:key][:kind]).to eq 'private_server'
    end

    it 'fails to create a new key for the authenticated user given no attributes' do
      log_in_user(u = create_verified_user!)

      api_post '/manager/keys', key: {}

      expect(response.status).to eq 422
      expect(json[:errors]).to be_present
    end

    it 'fails if not authenticated' do
      api_headers['Authorization'] = 'Token ' + Token.generate(:session, user_id: 'herp').to_s

      api_post '/manager/keys'

      expect(response.status).to eq 401
    end
  end

  describe 'PUT /manager/keys/:id' do
    it 'updates the key owned by the authenticated user' do
      u1 = create_verified_user!
      u2 = create_verified_user!
      k1 = create_key!(user_id: u1)
      k2 = create_key!(user_id: u2)

      log_in_user(u1)

      api_put "/manager/keys/#{k1.id}", key: {
        label: 'Nu Label',
        info: 'Nu Infos'
      }

      k1.reload

      expect(response.status).to eq 204
      expect(k1.label).to eq 'Nu Label'
      expect(k1.info).to eq 'Nu Infos'

      expect {
        api_put "/manager/keys/#{k2.id}", key: {
          info: nil
        }
      }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'fails if not authenticated' do
      api_headers['Authorization'] = 'Token ' + Token.generate(:session, user_id: 'herp').to_s
      u = create_verified_user!
      k = create_key!(user_id: u)

      api_put "/manager/keys/#{k.id}", key: { label: 'Derp' }

      expect(response.status).to eq 401
    end
  end

  describe 'DELETE /manager/keys/:id' do
    it 'deletes the key owned by the authenticated user' do
      u1 = create_verified_user!
      u2 = create_verified_user!
      k1 = create_key!(user_id: u1)
      k2 = create_key!(user_id: u2)

      log_in_user(u1)

      api_delete "/manager/keys/#{k1.id}"

      expect(response.status).to eq 204
      expect(Key.exists?(k1.id)).to eq false

      expect {
        api_delete "/manager/keys/#{k2.id}"
      }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'fails if not authenticated' do
      u = create_verified_user!
      k = create_key!(user_id: u)

      api_headers['Authorization'] = 'Token ' + Token.generate(:session, user_id: u.id).to_s

      api_delete "/manager/keys/#{k.id}"

      expect(response.status).to eq 401
    end
  end
end
