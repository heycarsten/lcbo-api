require 'spec_helper'

describe 'Inventory resources routing' do
  it '/inventories' do
    { :get => '/inventories' }.should route_to(
      :controller => 'inventories',
      :action => 'index',
      :version => 2
    )
  end

  it '/products/:products_id/inventories' do
    { :get => '/products/18/inventories' }.should route_to(
      :controller => 'inventories',
      :product_id => '18',
      :action => 'index',
      :version => 2
    )
  end

  it '/stores/:store_id/products/:products_id/inventory' do
    { :get => '/stores/511/products/18/inventory' }.should route_to(
      :controller => 'inventories',
      :action => 'show',
      :store_id => '511',
      :product_id => '18',
      :version => 2
    )
  end
end
