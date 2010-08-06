require 'spec_helper'

describe Mongoid::Archive do

  class TestDoc
    include Mongoid::Document
    include Mongoid::Archive
    archive :day, [:qty]
    field :name
    field :qty, :type => Integer, :default => 0
    field :day, :type => Integer, :default => 0
  end

  context 'when mixed into a document' do
    it 'should create a new document for updates' do
      TestDocUpdate.should be_a(Class)
      TestDocUpdate.should respond_to(:index, :field, :key)
    end

    it 'should copy tracked fields to the new document' do
      archive_fields = TestDoc.archive_fields.map(&:to_s)
      TestDocUpdate.fields.keys.should include(*archive_fields)
    end

    it 'should include the primary field in the list of fields' do
      TestDoc.archive_fields.should include(:day)
    end

    it 'should provide an embed_many in the host document' do
      TestDoc.associations.keys.should include('updates')
    end

    it 'should reflect an embed_many in the update document' do
      TestDocUpdate.embedded?.should be_true
    end
  end

  context 'when a document is first created' do
    before :all do
      @doc = TestDoc.create(:name => 'test', :qty => 5, :day => 1)
    end

    it 'should not have any updates' do
      @doc.updates.should be_empty
    end
  end

  context 'when a document changes but no tracked fields change' do
    before :all do
      @doc = TestDoc.create(:name => 'test', :qty => 5, :day => 1)
      @doc.update_attributes(:name => 'test2', :qty => 5, :day => 1)
    end

    it 'should create any updates' do
      @doc.updates.should be_empty
    end
  end

  context 'when a document changes and the tracked field changes' do
    before :all do
      @doc = TestDoc.create(:name => 'test', :qty => 5, :day => 1)
      @doc.update_attributes(:name => 'test', :qty => 4, :day => 2)
    end

    it 'should save one update' do
      @doc.updates.size.should == 1
    end

    it 'should save the previous state as an update' do
      doc = @doc.updates.first.should
      doc.qty.should == 5
      doc.day.should == 1
    end
  end

end
