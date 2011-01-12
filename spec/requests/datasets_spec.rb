require 'spec_helper'

describe 'Datasets resources' do
  before :all do
    clean_database

    @crawl1 = Fabricate(:crawl)
    @crawl2 = Fabricate(:crawl)
    @crawl3 = Fabricate(:crawl)
  end

  context '/datasets' do
    before { get '/datasets' }
    it_should_behave_like 'a JSON response'
    it 'returns datasets' do
      response.json[:result].should be_a Array
      response.json[:result].size.should == 3
    end
  end

  context '/datasets.json' do
    before { get '/datasets.json' }
    it_should_behave_like 'a JSON response'
  end

  context '/datasets.json?callback=test' do
    before { get '/datasets.json?callback=test' }
    it_should_behave_like 'a JSON-P response'
  end

  context '/datasets.js?callback=test' do
    before { get '/datasets.js?callback=test' }
    it_should_behave_like 'a JSON-P response'
  end

  context '/datasets.csv' do
    before { get '/datasets.csv' }
    it_should_behave_like 'a CSV response'
  end

  context '/datasets/:id.csv' do
    before { get "/datasets/#{@crawl1.id}.csv" }
    it_should_behave_like 'a CSV response'
  end

  context '/datasets.tsv' do
    before { get '/datasets.tsv' }
    it_should_behave_like 'a TSV response'
  end

  context '/datasets/:id.tsv' do
    before { get "/datasets/#{@crawl1.id}.tsv" }
    it_should_behave_like 'a TSV response'
  end

  context '/datasets/:id' do
    before { get "/datasets/#{@crawl1.id}" }
    it_should_behave_like 'a JSON response'
  end
end