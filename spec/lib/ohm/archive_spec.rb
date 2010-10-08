require 'spec_helper'

class Post < Ohm::Model
  include Ohm::Typecast
  include Ohm::Archive
  attribute :name, String
  attribute :msg,  String
  attribute :qty,  Integer
  attribute :date, String
  archive :date, [:msg, :qty]
end

describe Ohm::Archive do
  before :all do
    @post = Post.create(
      :name => 'tim',
      :msg => 'hi',
      :qty => 0,
      :date => '2010-01-01')
  end

  describe 'commiting for the first time' do
    before :all do
      @post.commit
    end

    it 'should create a revision' do
      @post.revisions.count.should == 1
    end
  end

  describe 'commiting a second time without changing the indexed attribute' do
    before :all do
      @post.update_attributes(:msg => 'hello')
      @post.save
      @post.commit
    end

    it 'should not create a new revision' do
      @post.revisions.count.should == 1
    end

    it 'should update the existing revision' do
      @post.revisions.first.msg.should == 'hello'
    end
  end

  describe 'updating the object and the indexed field' do
    before :all do
      @post.update_attributes(:qty => 1, :date => '2010-01-02')
      @post.save
      @post.commit
    end

    it 'should update fields that changed' do
      @post.qty.should == 1
      @post.date.should == '2010-01-02'
    end

    it 'should create a new revision' do
      @post.revisions.count.should == 2
    end
  end
end
