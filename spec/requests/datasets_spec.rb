require 'spec_helper'

describe 'Datasets resources' do
  before :all do
    clean_database

    @crawl1 = Fabricate(:crawl)
    @crawl2 = Fabricate(:crawl)
    @crawl3 = Fabricate(:crawl)
  end

  describe '/datasets' do
    subject { '/datasets' }
    it_behaves_like 'a resource', :size => 3
  end

  describe '/datasets/:id' do
    subject { "/datasets/#{@crawl1.id}" }
    it_behaves_like 'a resource'
  end

end
