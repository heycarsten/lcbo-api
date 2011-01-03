require 'spec_helper'

describe 'Revision resources routing' do
  it 'routes /stores/:store_id/history' do
    { :get => '/stores/511/history' }.should route_to(
      :controller => 'revisions',
      :action => 'index',
      :store_id => '511',
      :version => 2
    )
  end

  it 'routes /products/:product_id/history' do
    { :get => '/products/18/history' }.should route_to(
      :controller => 'revisions',
      :action => 'index',
      :product_id => '18',
      :version => 2
    )
  end

  it 'routes /stores/:store_id/products/:product_id/history' do
    { :get => '/stores/511/products/18/history' }.should route_to(
      :controller => 'revisions',
      :action => 'index',
      :store_id => '511',
      :product_id => '18',
      :version => 2
    )
  end
end
