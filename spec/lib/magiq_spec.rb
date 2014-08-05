require 'rails_helper'

RSpec.describe Magiq::Query do
  class MockScope
    attr_reader :args, :data

    def initialize
      @data = {}
      @args = Hash.new { |h, k| h[k] = [] }
    end

    def merge(h)
      @data.update(h)
      self
    end

    [:where, :order, :page, :per].each do |slot|
      define_method(:"#{slot}_args") do
        @args[slot]
      end

      define_method(slot) do |*args|
        @args[slot] << args
        self
      end
    end
  end

  class MockModel
    def self.arel_table
      Class.new {
        attr_reader :field

        def [](field)
          @field = field

          Class.new {
            def gt(col); end
            def lt(col); end
            def gte(col); end
            def lte(col); end
          }.new
        end
      }.new
    end

    def self.unscoped
      MockScope.new
    end
  end

  class MockQuery < Magiq::Query
    attr_reader :dis, :dat

    model { MockModel }

    has_pagination

    equal :id, type: :id, array: true, alias: :ids

    param :lat, type: :latitude
    param :lon, type: :longitude
    apply :lat, :lon do |lat, lon|
      scope.merge(lat: lat, lon: lon)
    end

    param :geo

    mutual [:lat, :lon], exclusive: :geo

    param :total, type: :whole
    apply :total do |val|
      scope.merge(total: val)
    end

    param :temp, type: :float
    apply :temp do |val|
      scope.merge(temp: val)
    end

    param :place, type: :int
    apply :place do |val|
      scope.merge(place: val)
    end

    bool \
      :is_awesome,
      :is_nawsome

    order :distance
    range :distance, type: :whole

    check :temp do |val|
      next unless val < -273.15
      bad! "Temperatures can't be below absolute zero Celsius!"
    end

    param :dis
    param :dat

    apply :dis, :dat, any: true do |dis, dat|
      @dis = dis
      @dat = dat
      scope.merge(dis: dis, dat: dat)
    end
  end

  subject { MockQuery }

  it 'allows parameter listeners to be registered' do
    expect(subject.builder.listeners.size).to_not eq 0
  end

  it 'allows parameter checkers to be registered' do
    expect {
      subject.new(temp: '-200.15').to_scope
    }.to_not raise_error

    expect {
      subject.new(temp: '-350').to_scope
    }.to raise_error Magiq::BadParamError
  end

  it 'can apply scope' do
    s = subject.new(lat: '40.5', lon: '78.2').to_scope

    expect(s.data[:lat]).to eq 40.5
    expect(s.data[:lon]).to eq 78.2
  end

  it 'understands that mutual parameters must appear together' do
    expect {
      subject.new(lat: '48.44335').to_scope
    }.to raise_error Magiq::ParamsError

    expect {
      subject.new(lat: '43.38384', lon: '38.33942').to_scope
    }.to_not raise_error
  end

  it 'understands that mutual parameters can have exclusive counterparts' do
    expect {
      subject.new(
        lat: '45.838383',
        lon: '-73.83838',
        geo: 'hiiiii'
      ).to_scope
    }.to raise_error Magiq::ParamsError

    expect {
      subject.new(
        geo: 'hiiii'
      ).to_scope
    }.to_not raise_error
  end

  it 'understands that exclusive parameters can not appear together' do
    subject.exclusive :distance_gt, :distance_gte

    expect {
      subject.new(
        distance_gt: '400',
        distance_gte: '300'
      ).to_scope
    }.to raise_error Magiq::ParamsError
  end

  it 'understands that solo parameters are not to be mixed with others' do
    expect {
      subject.new(
        id: '100',
        geo: 'hiiiii'
      ).to_scope
    }.to raise_error Magiq::BadParamError
  end

  it 'understands that array params can be supplied' do
    s = subject.new(id: ['1', '2', '3']).to_scope

    expect(s.where_args[0][0][:id]).to include 1, 2, 3
  end

  it 'runs apply hooks if any dependent attributes are provided when :any option is specified' do
    s = subject.new(dat: 'yayo!')
    s.to_scope

    expect(s.dis).to eq nil
    expect(s.dat).to eq 'yayo!'
  end

  it 'applies pagination always' do
    s = subject.new(dat: 'coo').to_scope

    expect(s.page_args[0].size).to eq 1
  end

  it 'does not apply pagination if a solo param is specified' do
    s = subject.new(id: '20').to_scope

    expect(s.page_args.size).to eq 0
  end

  it 'allows parameter names to have aliases' do
    s = subject.new(ids: ['20', '30']).to_scope

    expect(s.where_args[0][0][:id]).to include 20, 30
  end
end
