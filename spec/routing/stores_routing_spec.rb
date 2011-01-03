require 'spec_helper'

describe 'Store resources routing' do
  it 'routes /stores' do
    { :get => '/stores' }.should route_to(
      :controller => 'stores',
      :action => 'index',
      :version => 2
    )
  end

  it 'routes /stores/:id' do
    { :get => '/stores/511' }.should route_to(
      :controller => 'stores',
      :action => 'show',
      :id => '511',
      :version => 2
    )
  end

  it 'routes /products/:product_id/stores' do
    { :get => '/products/18/stores' }.should route_to(
      :controller => 'stores',
      :action => 'index',
      :product_id => '18',
      :version => 2
    )
  end
end
