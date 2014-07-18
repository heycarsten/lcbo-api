require 'rails_helper'

RSpec.describe Magiq::Query do
  class MockModel
    def self.unscoped; {}; end
    def self.merge(hsh); unscoped.merge(hsh); end
  end

  subject do
    Class.new(Magiq::Query) { self.model = Class.new(MockModel) }
  end

  it 'allows parameter matchers to be registered' do
    subject.match(:hi) {}
    expect(subject.builder.listeners.size).to eq 1
  end

  it 'matches to the end of parameter names' do
    cool = {}

    subject.match('{param}_hi') do |value, param|
      cool[:value] = value
      cool[:param] = param
    end

    subject.new(carsten_hi: 'yo').fire_listeners!

    expect(cool[:value]).to eq 'yo'
    expect(cool[:param]).to eq :carsten
  end

  it 'matches to the start of parameter names' do
    cool = {}

    subject.match('yo_{param}') do |value, param|
      cool[:value] = value
      cool[:param] = param
    end

    subject.new(yo_carsten: 'yo').fire_listeners!

    expect(cool[:value]).to eq 'yo'
    expect(cool[:param]).to eq :carsten
  end

  it 'matches to the start and end of parameter names' do
    cool = {}

    subject.match('yo_{param}_hi') do |value, param|
      cool[:value] = value
      cool[:param] = param
    end

    subject.new(yo_carsten_hi: 'yo').fire_listeners!

    expect(cool[:value]).to eq 'yo'
    expect(cool[:param]).to eq :carsten
  end

  it 'can derrive model via ::model_name' do
    subject.model = nil
    subject.model_name = :mock_model
    expect(subject.model).to be MockModel
  end

  it 'can apply scope' do
    subject.match '{param}_has_fun' do |val, param|
      apply_scope do |scope|
        scope.merge(param => val)
      end
    end

    s = subject.new(carsten_has_fun: true, mattia_has_fun: true).to_scope

    expect(s[:carsten]).to eq true
    expect(s[:mattia]).to eq true
  end

  it 'understands that mutual parameters must appear together' do
    subject.mutual [:lat, :lon]

    expect {
      subject.new(lat: '48.44335').verify_constraints!
    }.to raise_error Magiq::ParamsError

    expect {
      subject.new(lat: '43.38384', lon: '3838.339494').verify_constraints!
    }.to_not raise_error
  end

  it 'understands that mutual parameters can have exclusive counterparts' do
    subject.mutual [:lat, :lon], exclusive: :geo

    expect {
      subject.new(
        lat: '45.838383',
        lon: '-73.83838',
        geo: 'hiiiii'
      ).verify_constraints!
    }.to raise_error Magiq::ParamsError

    expect {
      subject.new(
        geo: 'hiiii'
      ).verify_constraints!
    }.to_not raise_error
  end

  # it 'understands that exclusive parameters must not appear together' do
  #   subject.exclusive :farts_gt, :farts_gte

  #   expect {
  #     subject.new(fart_rate_gt: 10, fart_rate_gte: 11).validate!
  #   }
  # end

  # describe '::page_size' do
  #   it 'has a default' do
  #     expect(subject.page_size).to eq Magiq.config[:page_size]
  #   end

  #   it 'can be changed' do
  #     subject.page_size = 20
  #     expect(subject.page_size).to eq 20
  #   end
  # end

  # it 'can override attributes' do
  #   subject.attribute :name, param: :givenName
  # end
end
