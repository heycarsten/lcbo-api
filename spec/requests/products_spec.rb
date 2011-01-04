require 'spec_helper'

describe 'Product resources' do
  before :all do
    clean_database

    @product1 = Fabricate(:product)
    @product2 = Fabricate(:product, :name => 'Fitzgibbons')
    @store1   = Fabricate(:store)
    @inv1     = Fabricate(:inventory, :store => @store1, :product => @product1)

    Fuzz.recache
  end

  context '/products' do
    before do
      get '/products'
    end

    it_should_behave_like 'a JSON response'
  end

  context '/products?q= (full text hit)' do
    before do
      get '/products?q=fitzgibbons'
    end

    it_should_behave_like 'a JSON response'

    it 'contains a matched product' do
      response.json[:result].size.should == 1
      response.json[:result][0].should be_a Hash
      response.json[:result][0][:id].should == @product2.id
    end

    it 'does not contain a suggestion' do
      response.json[:suggestion].should be_nil
    end
  end

  context '/products?q= (full text miss)' do
    before do
      get '/products?q=fitzgibins'
    end

    it_should_behave_like 'a JSON response'

    it 'does not contain a product resource' do
      response.json[:result].should be_a Array
      response.json[:result].size.should be_zero
    end

    it 'contains a suggestion' do
      response.json[:suggestion].should == 'fitzgibbons'
    end
  end

  context '/products/:id' do
    before do
      get "/products/#{@product1.id}"
    end

    it_should_behave_like 'a JSON response'
  end

  context '/products/:id (not found)' do
    before do
      get "/products/1"
    end

    it_should_behave_like 'a JSON 404 error'
  end

end
