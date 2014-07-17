require 'rails_helper'

RSpec.describe 'V2 Manager Verifications API' do
  describe 'PUT /manager/verifications/:token' do
    it 'returns a session for a valid email token' do
      u = create_user!
      e = u.new_email
      t = e.verification_token

      expect(u.email).to be_blank

      api_put "/manager/verifications/#{t}"

      u.reload

      expect(response.status).to eq 200
      expect(u.email).to be_present
      expect(json[:session][:token]).to be_present

      api_put "/manager/verifications/#{t}"

      expect(response.status).to eq 404
    end

    it 'fails for an invalid token' do
      t = Token.generate(:email_verification)

      api_put "/manager/verifications/#{t}"

      expect(response.status).to eq 404
      expect(json[:error][:detail]).to be_present
    end
  end
end
