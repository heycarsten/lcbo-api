require 'spec_helper'

describe 'Product resources routing' do
  it 'routes /products' do
    { :get => '/products' }.should route_to(
      :controller => 'products',
      :action => 'index',
      :version => 2
    )
  end

  it 'routes /products/:id' do
    { :get => '/products/18' }.should route_to(
      :controller => 'products',
      :action => 'show',
      :id => '18',
      :version => 2
    )
  end

  it 'routes /stores/:store_id/products' do
    { :get => '/stores/511/products' }.should route_to(
      :controller => 'products',
      :action => 'index',
      :store_id => '511',
      :version => 2
    )
  end
end
