require 'spec_helper'

describe Crawl do
  after :each do
    @crawl && @crawl.destroy
  end

  describe 'given there are no active crawls' do
    it 'should allow a new crawl to be initial  ized' do
      -> { Crawl.init }.should_not raise_error
    end
  end

  describe 'given there is an active crawl' do
    it 'should raise an error' do
      -> { Crawl.init; Crawl.init }.should raise_error(Crawl::AlreadyRunningError)
    end
  end
end
