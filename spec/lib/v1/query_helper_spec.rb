require 'spec_helper'

class BaseQuery < V1::QueryHelper::Query
  def initialize(*args)
    super
    validate
  end

  def self.model
    @model ||= Class.new(ActiveRecord::Base)
  end

  def self.model_name
    :base
  end

  def self.table
    :bases
  end

  def self.sortable_fields
    %w[ height weight quantity ]
  end

  def self.filterable_fields
    %w[ has_thumbs is_cool ]
  end

  def self.where
    []
  end

  def self.where_not
    []
  end
end

class MockFormat
  def initialize(format = 'json')
    @format = format
  end

  def method_missing(name)
    @format == name.to_s.sub('?', '')
  end

  def to_s
    format.to_s
  end
end

def mkreq(fullpath, format = 'json')
  Struct.new(:fullpath, :format).new(fullpath, MockFormat.new(format))
end

def mkquery(type, params = {})
  q = params.reduce([]) { |pairs, (k,v)|
      pairs << "#{k}=#{Rack::Utils.escape(v)}"
    }.join('&')
  path = "/#{type}?#{q}"
  case type
  when :stores
    V1::QueryHelper::StoresQuery.new(mkreq(path), params)
  when :products
    V1::QueryHelper::ProductsQuery.new(mkreq(path), params)
  when :lambda
    LambdaTableQuery.new(mkreq(path), params)
  else
    BaseQuery.new(mkreq(path), params)
  end
end

describe BaseQuery do
  describe '#page' do
    ['0', 0, 'x x'].each do |page|
      it "should not allow value: #{page.inspect}" do
        expect {
          mkquery(nil, page: page)
        }.to raise_error V1::QueryHelper::BadQueryError
      end
    end
  end

  describe '#per_page' do
    ['0', '4', '201', '-12'].each do |per_page|
      it "should not allow value: #{per_page.inspect}" do
        expect {
          mkquery(nil, per_page: per_page)
        }.to raise_error V1::QueryHelper::BadQueryError
      end
    end
  end

  describe '#order' do
    it 'allows ordering by whitelisted value' do
      o = mkquery(nil, order: 'height.desc').order
      expect(o[0]).to eq 'bases.height DESC NULLS LAST'
    end

    it 'is not case sensitive' do
      o = mkquery(nil, order: 'Height.Desc').order
      expect(o[0]).to eq 'bases.height DESC NULLS LAST'
    end

    it 'allows for a list of values' do
      o = mkquery(nil, order: 'height.desc,weight.asc').order
      expect(o[0]).to eq 'bases.height DESC NULLS LAST'
      expect(o[1]).to eq 'bases.weight ASC NULLS LAST'
    end

    it 'rejects incorrect values' do
      expect {
        mkquery(nil, order: 'height.asc,weight.desk')
      }.to raise_error V1::QueryHelper::BadQueryError

      expect {
        mkquery(nil, order: 'SELECT * FROM products;')
      }.to raise_error V1::QueryHelper::BadQueryError

      expect {
        mkquery(nil, order: 'hite.asc')
      }.to raise_error V1::QueryHelper::BadQueryError
    end
  end

  describe '#where' do
    it 'should only allow whitelisted values' do
      expect(mkquery(nil, where: 'has_thumbs').where).
        to eq %w[ has_thumbs ]

      expect(mkquery(nil, where: 'is_cool, has_thumbs').where).
        to eq %w[ is_cool has_thumbs ]

      expect(mkquery(nil, where: 'is_cool,has_thumbs').where).
        to eq %w[ is_cool has_thumbs ]

      expect {
        mkquery(nil, where: 'has_coolness')
      }.to raise_error(V1::QueryHelper::BadQueryError)
    end

    it 'should not allow same values as #where_not' do
      expect {
        mkquery(nil,
          where: 'is_cool,has_thumbs',
          where_not: 'is_cool')
      }.to raise_error(V1::QueryHelper::BadQueryError)
    end
  end

  describe '#where_not' do
    it 'should only allow whitelisted values' do
      expect(mkquery(nil, where: 'has_thumbs').where).
        to eq %w[ has_thumbs ]

      expect(mkquery(nil, where: 'is_cool, has_thumbs').where).
        to eq %w[ is_cool has_thumbs ]

      expect(mkquery(nil, where: 'is_cool,has_thumbs').where).
        to eq %w[ is_cool has_thumbs ]

      expect {
        mkquery(nil, where: 'has_coolness')
      }.to raise_error(V1::QueryHelper::BadQueryError)
    end
  end

  describe '#filter_hash' do
    it 'should set where fields to true and where_not fields to false' do
      q = mkquery(nil,
        where: 'is_cool',
        where_not: 'has_thumbs')

      expect(q.filter_hash['bases.is_cool']).to eq true
      expect(q.filter_hash['bases.has_thumbs']).to eq false
    end
  end
end

describe V1::QueryHelper::ProductsQuery do
  before do
    Fabricate(:product, name: 'Magic Merlot')
    Fabricate(:product, name: 'Sassy Shiraz')
    Fabricate(:product, name: 'Tasty Stout')
    Fabricate(:product, name: 'Fresh Cider')
    Fabricate(:product, name: 'Classy Cabernet')
    Fabricate(:product, name: 'Fabulous Cooler')
    Fabricate(:product, name: 'Nonsecular Vodka')
    Fabricate(:product, name: 'Bayport Swill')
    Fabricate(:product, name: 'Bucko\'s Sherry')
    Fabricate(:product, name: 'Catindividual Wine')
  end

  it 'should allow for a full-text query' do
    q = mkquery(:products, q: 'fresh')
    expect(q.scope.load.size).to eq 1
  end
end

describe V1::QueryHelper::StoresQuery do
  before do
    @store_1  = Fabricate(:store, name: 'Toronto',  latitude: 43.65285, longitude: -79.38143)
    @store_2  = Fabricate(:store, name: 'London',   latitude: 42.97941, longitude: -81.24608)
    @store_3  = Fabricate(:store, name: 'Barrie',   latitude: 44.39072, longitude: -79.68593)
    @store_4  = Fabricate(:store, name: 'Kingston', latitude: 44.26359, longitude: -76.50330)
    @store_5  = Fabricate(:store, name: 'Aurora',   latitude: 44.00660, longitude: -79.45063)
    @store_6  = Fabricate(:store, name: 'Bradford', latitude: 44.12027, longitude: -79.56178)
    @store_7  = Fabricate(:store, name: 'Minesing', latitude: 44.44291, longitude: -79.84226)
    @store_8  = Fabricate(:store, name: 'Hamilton', latitude: 43.24361, longitude: -79.88889)
    @store_9  = Fabricate(:store, name: 'Oshawa',   latitude: 43.88996, longitude: -78.85997)
    @store_10 = Fabricate(:store, name: 'Guelph',   latitude: 43.53881, longitude: -80.24763)

    @product  = Fabricate(:product, name: 'Mild Ale')

    @inv_1 = Fabricate(:inventory, store_id: @store_1.id, product_id: @product.id)
    @inv_2 = Fabricate(:inventory, store_id: @store_2.id, product_id: @product.id)
    @inv_3 = Fabricate(:inventory, store_id: @store_3.id, product_id: @product.id)
    @inv_4 = Fabricate(:inventory, store_id: @store_4.id, product_id: @product.id)
  end

  it 'should create @product' do
    expect(@product).to be_persisted
  end

  it 'should create @store_1' do
    expect(@store_1).to be_persisted
  end

  it 'should create @inv_1' do
    expect(@inv_1).to be_persisted
  end

  it 'should have @product on hand at @store_1' do
    expect(Inventory.where(store_id: @store_1.id, product_id: @product.id).first).
      not_to eq nil
  end

  ['-91.9191', '91.1111', 'x+x'].each do |lat|
    it "should not allow #{lat.inspect} as a latitude" do
      expect {
        mkquery(:stores, lat: lat)
      }.to raise_error V1::QueryHelper::BadQueryError
    end
  end

  ['-191.9191', '191.1111', 'x+x'].each do |lon|
    it "should not allow #{lon.inspect} as a longitude" do
      expect {
        mkquery(:stores, lon: lon)
      }.to raise_error V1::QueryHelper::BadQueryError
    end
  end

  it 'should require both :lat and :lon be present if only one is present' do
    expect {
      mkquery(:stores, lat: '43.0')
    }.to raise_error V1::QueryHelper::BadQueryError

    expect {
      mkquery(:stores, lon: '-78.0')
    }.to raise_error V1::QueryHelper::BadQueryError
  end

  it 'should not allow :lat or :lon in combination with :geo' do
    expect {
      mkquery(:stores, lat: '43.0', lon: '-78.0', geo: 'a place')
    }.to raise_error V1::QueryHelper::BadQueryError
  end

  describe 'A spatial query via :lat and :lon' do
    before do
      @lat = 43.65285
      @lon = -79.38143
      @q = mkquery(:stores, lat: @lat.to_s, lon: @lon.to_s)
    end

    it 'should setup a spatial query' do
      expect(@q.latitude).to eq @lat
      expect(@q.longitude).to eq @lon
      expect(@q.scope).to be_a ActiveRecord::Relation
    end
  end

  describe 'A spatial query via :geo' do
    before do
      @point = Struct.new(:lat, :lng).new(43.65285, -79.38143)
      @q = mkquery(:stores, geo: 'city hall')
      @q.instance_variable_set(:@geocode, @point)
    end

    it 'should allow geospatial lookups using :geo' do
      expect(@q.latitude).to eq @point.lat
      expect(@q.longitude).to eq @point.lng
    end
  end

  describe 'A spatial query via :lat and :lon with :product_id' do
    before do
      @lat = 43.65285
      @lon = -79.38143
      @q   = mkquery :stores,
        lat: @lat.to_s,
        lon: @lon.to_s,
        product_id: @product.id.to_s
    end

    it 'should set up a spatial query with product_id' do
      expect(@q.latitude).to eq @lat
      expect(@q.longitude).to eq @lon
      expect(@q.product_id).to eq @product.id
      expect(@q.is_spatial?).to eq true
    end

    it 'should construct a dataset' do
      expect(@q.scope.load.size).to eq 4
      expect(@q.scope.first.distance_in_meters).to be < 10
    end

    it 'should provide paging params' do
      expect(@q.pager).to be_a Hash
    end
  end
end
