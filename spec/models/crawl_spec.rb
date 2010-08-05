require 'spec_helper'

describe Crawl do
  context '(scopes)' do
    before :all do
      @finished = Fabricate(:crawl,
        :did_start => true, :did_finish => true,  :did_fail => false)
      @failed   = Fabricate(:crawl,
        :did_start => true, :did_finish => false, :did_fail => true)
      @progress = Fabricate(:crawl,
        :did_start => true, :did_finish => false, :did_fail => false)
    end

    it 'should return a crawl that has failed' do
      Crawl.failed.first.timestamp.should == @failed.timestamp
    end

    it 'should return a crawl that is complete' do
      Crawl.finished.first.timestamp.should == @finished.timestamp
    end

    it 'should return a crawl that is in progress' do
      Crawl.in_progress.first.timestamp.should == @progress.timestamp
    end
  end

  context 'in progress' do
    before :all do
      @crawl = Fabricate(:crawl,
        :did_start => true, :did_finish => false, :did_fail => false)
    end

    it 'should not allow itself to be started again' do
      @crawl.start!.should be_nil
    end
  end

  context 'has failed' do
    before :all do
      @crawl = Fabricate(:crawl, :did_fail => true)
    end

    it 'should not be allowed to finish' do
      @crawl.finish!.should be_nil
    end

    it 'should not be allowed to start' do
      @crawl.start!.should be_nil
    end
  end

  context '(logging)' do
    before :each do
      @crawl = Fabricate(:crawl, :did_start => true)
    end

    it 'should allow a statement to be logged' do
      @crawl.log('test message', :test_job)
      @crawl.log_items.first.message.should == 'test message'
      @crawl.persisted?.should be_true
    end

    it 'should allow an exception to be logged' do
      begin
        raise 'test'
      rescue => error
        @crawl.log('test message', :test_job, error)
      end
      log = @crawl.log_items.first
      log.message.should == 'test message'
      log.error_class.should == 'RuntimeError'
      log.error_message.should == 'test'
      log.error_backtrace.should match /(.+\n)+/x
    end
  end
end
