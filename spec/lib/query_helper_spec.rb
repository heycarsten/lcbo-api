require 'spec_helper'

class BaseQuery < QueryHelper::Query
  def initialize(*args)
    super
    validate
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

def mkreq(fullpath)
  Struct.new(:fullpath).new(fullpath)
end

def mkquery(type, name, value)
  case type
  when :products
    lambda {
      QueryHelper::ProductsQuery.new(
        { name => value },
        mkreq("/products?#{name}=#{value}")
      )
    }
  when :stores
    lambda {
      QueryHelper::StoresQuery.new(
        { name => value },
        mkreq("/stores?#{name}=#{value}")
      )
    }
  else
    lambda {
      BaseQuery.new({ name => value }, mkreq("?#{name}=#{value}"))
    }
  end
end

describe BaseQuery do
  context '#page' do
    ['0', 0, 'x x'].each do |page|
      it "should not allow value: #{page.inspect}" do
        mkquery(nil, :page, page).
        should raise_error QueryHelper::BadQueryError
      end
    end
  end

  context '#per_page' do
    ['0', '4', '201', '-12'].each do |per_page|
      it "should not allow value: #{per_page.inspect}" do
        mkquery(nil, :per_page, per_page).
        should raise_error QueryHelper::BadQueryError
      end
    end
  end

  context '#sort_by' do
    it 'should only allow whitelisted values' do
      mkquery(nil, :sort_by, 'height').().sort_by.should == 'height'
      mkquery(nil, :sort_by, 'Height').().sort_by.should == 'height'
      mkquery(nil, :sort_by, 'age'   ).
        should raise_error(QueryHelper::BadQueryError)
    end
  end

  context '#order' do
    it 'should allow "asc" and "desc" as values' do
      mkquery(nil, :order, 'asc' ).().order.should == 'asc'
      mkquery(nil, :order, 'desc').().order.should == 'desc'
      mkquery(nil, :order, 'Asc' ).().order.should == 'asc'
      mkquery(nil, :order, 'Desc').().order.should == 'desc'
    end

    it 'should not allow other values' do
      mkquery(nil, :order, 'assc').
      should raise_error QueryHelper::BadQueryError
    end
  end

  context '#where' do
    it 'should only allow whitelisted values' do
      mkquery(nil, :where, 'has_thumbs').().where.
        should == %w[ has_thumbs ]
      mkquery(nil, :where, 'is_cool, has_thumbs').().where.
        should == %w[ is_cool has_thumbs ]
      mkquery(nil, :where, 'is_cool,has_thumbs').().where.
        should == %w[ is_cool has_thumbs ]
      mkquery(nil, :where, 'has_coolness').
        should raise_error(QueryHelper::BadQueryError)
    end

    it 'should not allow same values as #where_not' do
      -> {
        BaseQuery.new({
          :where => 'is_cool,has_thumbs',
          :where_not => 'is_cool'
        }, nil)
      }.should raise_error(QueryHelper::BadQueryError)
    end
  end

  context '#where_not' do
    it 'should only allow whitelisted values' do
      mkquery(nil, :where, 'has_thumbs').().where.
        should == %w[ has_thumbs ]
      mkquery(nil, :where, 'is_cool, has_thumbs').().where.
        should == %w[ is_cool has_thumbs ]
      mkquery(nil, :where, 'is_cool,has_thumbs').().where.
        should == %w[ is_cool has_thumbs ]
      mkquery(nil, :where, 'has_coolness').
        should raise_error(QueryHelper::BadQueryError)
    end
  end

  context '#filter_hash' do
    it 'should set where fields to true and where_not fields to false' do
      q = BaseQuery.new({
        :where => 'is_cool',
        :where_not => 'has_thumbs'
      }, nil)
      q.filter_hash[:is_cool].should == true
      q.filter_hash[:has_thumbs].should == false
    end
  end
end

describe QueryHelper::ProductsQuery do
  before :all do
    @pq = QueryHelper::ProductsQuery
    @product_1  = Fabricate(:product, :name => 'Magic Merlot')
    @product_2  = Fabricate(:product, :name => 'Sassy Shiraz')
    @product_3  = Fabricate(:product, :name => 'Tasty Stout')
    @product_4  = Fabricate(:product, :name => 'Fresh Cider')
    @product_5  = Fabricate(:product, :name => 'Classy Cabernet')
    @product_6  = Fabricate(:product, :name => 'Fabulous Cooler')
    @product_7  = Fabricate(:product, :name => 'Nonsecular Vodka')
    @product_8  = Fabricate(:product, :name => 'Bayport Swill')
    @product_9  = Fabricate(:product, :name => 'Bucko\'s Sherry')
    @product_10 = Fabricate(:product, :name => 'Catindividual Wine')
  end
  
  
end

describe QueryHelper::StoresQuery do
  before :all do
    @store_1  = Fabricate(:store, :name => 'Toronto',  :latitude => 43.65285, :longitude => -79.38143)
    @store_2  = Fabricate(:store, :name => 'London',   :latitude => 42.97941, :longitude => -81.24608)
    @store_3  = Fabricate(:store, :name => 'Barrie',   :latitude => 44.39072, :longitude => -79.68593)
    @store_4  = Fabricate(:store, :name => 'Kingston', :latitude => 44.26359, :longitude => -76.50330)
    @store_5  = Fabricate(:store, :name => 'Aurora',   :latitude => 44.00660, :longitude => -79.45063)
    @store_6  = Fabricate(:store, :name => 'Bradford', :latitude => 44.12027, :longitude => -79.56178)
    @store_7  = Fabricate(:store, :name => 'Minesing', :latitude => 44.44291, :longitude => -79.84226)
    @store_8  = Fabricate(:store, :name => 'Hamilton', :latitude => 43.24361, :longitude => -79.88889)
    @store_9  = Fabricate(:store, :name => 'Oshawa',   :latitude => 43.88996, :longitude => -78.85997)
    @store_10 = Fabricate(:store, :name => 'Guelph',   :latitude => 43.53881, :longitude => -80.24763)

    @product  = Fabricate(:product, :name => 'Mild Ale')

    @inv_1 = Fabricate(:inventory, :store_id => @store_1.id, :product_id => @product.id)
    @inv_2 = Fabricate(:inventory, :store_id => @store_2.id, :product_id => @product.id)
    @inv_3 = Fabricate(:inventory, :store_id => @store_3.id, :product_id => @product.id)
    @inv_4 = Fabricate(:inventory, :store_id => @store_4.id, :product_id => @product.id)
  end

  ['-91.9191', '91.1111', 'x+x'].each do |lat|
    it "should not allow #{lat.inspect} as a latitude" do
      mkquery(:stores, :lat, lat).should raise_error QueryHelper::BadQueryError
    end
  end

  ['-191.9191', '191.1111', 'x+x'].each do |lon|
    it "should not allow #{lon.inspect} as a longitude" do
      mkquery(:stores, :lon, lon).should raise_error QueryHelper::BadQueryError
    end
  end

  it 'should require both :lat and :lon be present if only one is present' do
    mkquery(:stores, :lat, '43.0').should raise_error QueryHelper::BadQueryError
    mkquery(:stores, :lon, '-78.0').should raise_error QueryHelper::BadQueryError
  end

  it 'should not allow :lat or :lon in combination with :geo' do
    -> {
      QueryHelper::StoresQuery.new({
        :lat => '43.0',
        :lon => '-78.0',
        :geo => 'a place'
      }, nil)
    }.should raise_error QueryHelper::BadQueryError
  end
end
