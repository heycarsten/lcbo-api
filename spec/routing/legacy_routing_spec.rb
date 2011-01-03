require 'spec_helper'

describe 'Legacy routing' do
  it 'routes /products/:product_no' do
    { :get => '/products/18' }.should route_to(
      :controller => 'products',
      :action => 'show',
      :id => '18',
      :version => 2
    )
  end

  it 'routes /products/search' do
    { :get => '/products/search' }.should route_to(
      :controller => 'products',
      :action => 'index',
      :version => 1
    )
  end

  it 'routes /stores/:store_no' do
    { :get => '/stores/511' }.should route_to(
      :controller => 'stores',
      :action => 'show',
      :id => '511',
      :version => 2
    )
  end

  it 'routes /stores/search' do
    { :get => '/stores/search' }.should route_to(
      :controller => 'stores',
      :action => 'index',
      :version => 1
    )
  end

  it 'routes /stores/:store_no/products/search' do
    { :get => '/stores/511/products/search' }.should route_to(
      :controller => 'products',
      :action => 'index',
      :store_id => '511',
      :version => 1
    )
  end

  it 'routes /products/:product_no/inventory' do
    { :get => '/products/18/inventory' }.should route_to(
      :controller => 'inventories',
      :action => 'index',
      :product_id => '18',
      :version => 1
    )
  end

  it 'routes /stores/:store_no/products/:product_no/inventory' do
    { :get => '/stores/511/products/18/inventory' }.should route_to(
      :controller => 'inventories',
      :action => 'show',
      :store_id => '511',
      :product_id => '18',
      :version => 2
    )
  end

  it 'routes /stores/near/:latitude/:longitude' do
    { :get => '/stores/near/43.0/-78.0' }.should route_to(
      :controller => 'stores',
      :action => 'index',
      :lat => '43.0',
      :lon => '-78.0',
      :version => 1
    )
  end

  it 'routes /stores/near/:postal_code' do
    { :get => '/stores/near/m6r3a1' }.should route_to(
      :controller => 'stores',
      :action => 'index',
      :geo => 'm6r3a1',
      :version => 1
    )
  end

  it 'routes /stores/near/geo?q=:uri_encoded_query' do
    { :get => '/stores/near/geo' }.should route_to(
      :controller => 'stores',
      :action => 'index',
      :is_geo_q => true,
      :version => 1
    )
  end

  it 'routes /stores/near/:latitude/:longitude/with/:product_no' do
    { :get => '/stores/near/43.0/-78.0/with/18' }.should route_to(
      :controller => 'stores',
      :action => 'index',
      :lat => '43.0',
      :lon => '-78.0',
      :product_id => '18',
      :version => 1
    )
  end

  it 'routes /stores/near/:postal_code/with/:product_no' do
    { :get => '/stores/near/m6r3a1/with/18' }.should route_to(
      :controller => 'stores',
      :action => 'index',
      :geo => 'm6r3a1',
      :product_id => '18',
      :version => 1
    )
  end

  it 'routes /stores/near/geo/with/:product_no?q=:uri_encoded_query' do
    { :get => '/stores/near/geo/with/18' }.should route_to(
      :controller => 'stores',
      :action => 'index',
      :product_id => '18',
      :is_geo_q => true,
      :version => 1
    )
  end

  it 'routes /download/current.zip' do
    { :get => '/download/current.zip' }.should route_to(
      :controller => 'datasets',
      :action => 'depricated',
      :format => 'zip',
      :version => 1
    )
  end

  it 'routes /download/:year-:month-:day.zip' do
    { :get => '/download/2010-10-10.zip' }.should route_to(
      :controller => 'datasets',
      :action => 'depricated',
      :year => '2010',
      :month => '10',
      :day => '10',
      :format => 'zip',
      :version => 1
    )
  end
end