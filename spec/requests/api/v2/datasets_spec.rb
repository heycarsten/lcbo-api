require 'rails_helper'

RSpec.describe 'V2 Datasets API' do
  def prepare!
    @user   = create_verified_user!
    @key    = @user.keys.create!(label: 'Example App', kind: :private_server)
    @crawls = [
      Fabricate(:crawl),
      Fabricate(:crawl),
      Fabricate(:crawl, state: 'cancelled')
    ]

    api_headers['Authorization'] = "Token #{@key}"
  end

  it 'returns datasets (GET /datasets)' do
    prepare!

    api_get '/datasets'

    expect(response.status).to eq 200
    expect(json[:meta][:pagination][:total_pages]).to eq 1
    expect(json[:datasets].size).to eq 2
    expect(json[:datasets][0][:links][:products]).to be_blank
    expect(json[:datasets][0][:links][:stores]).to be_blank
  end

  it 'returns one dataset (GET /datasets/:id)' do
    prepare!

    api_get "/datasets/#{@crawls[0].id}"

    expect(response.status).to eq 200
    expect(json[:dataset][:id]).to eq @crawls[0].id.to_s
  end

  it 'does not return hidden datasets' do
    prepare!

    expect {
      api_get "/datasets/#{@crawls[2].id}"
    }.to raise_error ActiveRecord::RecordNotFound
  end
end
