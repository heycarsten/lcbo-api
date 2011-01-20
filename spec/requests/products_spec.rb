require 'spec_helper'

describe 'Product resources' do
  before :all do
    clean_database

    @product1 = Fabricate(:product, :id => '1')
    @product2 = Fabricate(:product, :id => '2', :name => 'Fitzgibbons')
    @product3 = Fabricate(:product, :id => '3', :name => 'B\'ock hop bob-omb')
    @store1   = Fabricate(:store, :id => '1')
    @inv1     = Fabricate(:inventory, :store => @store1, :product => @product1)

    Fuzz.recache
  end

  it 'contains sane objects' do
    DB[:products].count.should == 3
    DB[:stores].count.should == 1
    DB[:inventories].count.should == 1
  end

  describe 'all products' do
    subject { '/products' }
    it_behaves_like 'a resource', :size => 3
  end

  describe 'full text search with match' do
    subject { '/products?q=fitzgibbons' }
    it_behaves_like 'a resource', :size => 1
  end

  describe 'full text search with match (JSON)' do
    before { get '/products?q=fitzgibbons' }

    it 'contains a matched product' do
      response.json[:result].size.should == 1
      response.json[:result][0].should be_a Hash
      response.json[:result][0][:name].should == 'Fitzgibbons'
      response.json[:result][0][:id].should == @product2.id
    end

    it 'does not contain a suggestion' do
      response.json[:suggestion].should be_nil
    end
  end

  describe 'full text search with spaces' do
    before do
      get '/products?q=fitz+gibbons'
    end

    it 'does not contain a product resource' do
      response.json[:result].should be_a Array
      response.json[:result].size.should be_zero
    end

    it 'contains a suggestion' do
      response.json[:suggestion].should == 'fitzgibbons'
    end
  end

  describe 'full text search with slab quotes' do
    before do
      get '/products?q=B%27ock'
    end

    it 'does contain a product' do
      response.json[:result].size.should == 1
      response.json[:result].first[:id].should == 3
    end
  end

  describe 'full text search with dashes' do
    before do
      get '/products?q=bob-omb'
    end

    it 'does contain a product' do
      response.json[:result].size.should == 1
      response.json[:result].first[:id].should == 3
    end
  end

  describe 'full text search with crazy characters' do
    before do
      get '/products?q=Holy%21+Swee333t+Explo%24io%21%21%23%24%23%24n'
    end

    it 'returns json' do
      response.json[:result].should be_a Array
    end
  end

  describe 'full text search without match (JSON)' do
    before do
      get '/products?q=fitzgibins'
    end

    it 'does not contain a product resource' do
      response.json[:result].should be_a Array
      response.json[:result].size.should be_zero
    end

    it 'contains a suggestion' do
      response.json[:suggestion].should == 'fitzgibbons'
    end
  end

  describe 'get product' do
    subject { "/products/#{@product1.id}" }
    it_behaves_like 'a resource'
  end

  describe 'get product (not found)' do
    before { get '/products/9999999'}
    it_behaves_like 'a JSON 404 error'
  end
end
