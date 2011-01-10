require 'spec_helper'

describe 'Datasets resources' do
  before :all do
    clean_database

    @crawl1 = Fabricate(:crawl)
    @crawl2 = Fabricate(:crawl)
    @crawl3 = Fabricate(:crawl)
  end

  context '/datasets' do
    before do
      get '/datasets'
    end

    it_should_behave_like 'a JSON response'

    it 'returns datasets' do
      response.json[:result].should be_a Array
      response.json[:result].size.should == 3
    end
  end

  context '/datasets/:id' do
    before do
      get "/datasets/#{@crawl1.id}"
    end

    it_should_behave_like 'a JSON response'
  end
end