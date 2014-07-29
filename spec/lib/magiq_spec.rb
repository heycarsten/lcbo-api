require 'rails_helper'

RSpec.describe Magiq::Query do
  class MockScope
    attr_reader :where_args, :order_args, :data

    def initialize
      @data = {}
      @where_factors = []
      @order_factors = []
    end

    def where(*args)
      @where_factors << args
      self
    end

    def merge(h)
      @data.update(h)
      self
    end

    def order(*args)
      @order_factors << args
      self
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

  subject do
    Class.new(Magiq::Query) do
      model { MockModel }

      equal :id, array: true

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
    end
  end

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
end
