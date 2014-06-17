require 'spec_helper'

describe 'Datasets API' do
  before do
    @crawls = [
      Fabricate(:crawl),
      Fabricate(:crawl),
      Fabricate(:crawl)
    ]
  end

  it 'responds with many datasets' do
    get '/datasets'

    expect(response).to be_success
    expect(response).to be_json
    expect(response.payload[:result].size).to eq 3
  end

  it 'responds with one dataset' do
    get "/datasets/#{@crawls[0].id}"

    expect(response).to be_success
    expect(response).to be_json
    expect(response.payload[:result][:id]).to eq @crawls[0].id
  end
end
