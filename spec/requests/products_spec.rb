require 'spec_helper'

describe 'Product resources' do
  before :all do
    clean_database

    @product = Fabricate(:product)
    @store   = Fabricate(:store)
    @inv     = Fabricate(:inventory, :store => @store, :product => @product)
  end

  context '/products' do
    before { get '/products' }

    it_should_behave_like 'a JSON response'
  end

  context '/products/:id' do
    before { get "/products/#{@product.id}" }

    it_should_behave_like 'a JSON response'
  end

end
