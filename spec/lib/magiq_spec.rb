require 'rails_helper'

RSpec.describe Magiq::Builder do
  subject { Class.new(Magiq::Builder) }

  it 'has a model' do
    subject.model_name = :user
    expect(subject.model).to be User
  end

  it 'has attributes' do
    subject.attribute :name
    expect(subject.attributes)
  end

  describe '::config' do
    it 'is like a hash' do
      expect(subject.config[:page_size]).to be_present
    end

    it 'is like an object' do
      expect(subject.config.page_size).to be_present
    end
  end

  describe '::page_size' do
    it 'has a default' do
      expect(subject.page_size).to eq Magiq.config[:page_size]
    end

    it 'can be changed' do
      subject.page_size = 20
      expect(subject.page_size).to eq 20
    end
  end

  it 'can override attributes' do
    subject.attribute :name, param: :givenName
  end
end
