require 'rails_helper'

RSpec.describe 'V2 Producers API' do
  before do
    @user = create_verified_user!
    @key  = @user.keys.create!(label: 'Example App', kind: :private_server)
    @producers = [
      create_producer!,
      create_producer!,
      create_producer!
    ]

    api_headers['Authorization'] = "Token token=\"#{@key}\""
  end

  def get_many(params = {})
    api_get '/v2/producers'

    @data = response.json[:data]
    @meta = response.json[:meta]

    expect(response.status).to eq 200
  end

  it 'can get a producer' do
    api_get "/v2/producers/#{@producers[0].id}"

    data = response.json[:data]

    expect(response.status).to eq 200
    expect(data[:type]).to eq 'producer'
    expect(data[:id]).to eq @producers[0].id.to_s
  end

  it 'can get many producers' do
    get_many

    expect(@data.size).to eq 3
  end
end
