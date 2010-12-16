LCBOAPI::Application.routes.draw do

  namespace :admin do
    root :to => 'crawls#index'
    resources :crawls
    resources :crawl_events
  end

  root :to => 'root#index'

  scope :via => :get  do
    match '/docs'       => 'documents#index', :as => :documents
    match '/docs/:slug' => 'documents#show',  :as => :document
    match '/reflect'    => 'reflection#show', :as => :reflection
  end

  scope :version => 1, :via => :get do
    match '/download/:filename'                     => 'datasets#depricated'
    match '/download/current'                       => 'datasets#current', :format => 'zip'
    match '/stores/:store_id/products/:product_id/inventory' => 'inventories#show'
    match '/stores/:store_id/products/search'       => 'products#index'
    match '/products/search'                        => 'products#index'
    match '/stores/near/:lat/:lon/with/:product_id' => 'stores#index'
    match '/stores/near/geo/with/:product_id'       => 'stores#index', :is_geo => true
    match '/stores/near/:geo/with/:product_id'      => 'stores#index'
    match '/stores/near/:lat/:lon'                  => 'stores#index'
    match '/stores/near/geo'                        => 'stores#index', :is_geo => true
    match '/stores/near/:geo'                       => 'stores#index'
    match '/stores/search'                          => 'stores#index'
  end

  scope :version => 2, :via => :get do
    match '/datasets'                               => 'datasets#index'
    match '/datasets/current'                       => 'datasets#current'
    match '/datasets/current.zip'                   => 'datasets#current', :format => 'zip'
    match '/datasets/archive.zip'                   => 'datasets#archive', :format => 'zip'
    match '/datasets/:id'                           => 'datasets#show'
    match '/datasets/:id.zip'                       => 'datasets#show'
    match '/products/:product_id/inventory'         => 'inventories#show'
    match '/stores/:store_no/products/:product_no'  => 'inventories#show'
    match '/stores/:store_no/products/:product_no/history' => 'inventories#revisions'
    match '/stores/:store_no/products'              => 'inventories#products'
    match '/products/:product_no/stores'            => 'inventories#stores'
    match '/stores'                                 => 'stores#index'
    match '/products'                               => 'products#index'
    match '/products/:id'                           => 'products#show'
    match '/products/:id/history'                   => 'products#revisions'
    match '/stores/:id'                             => 'stores#show'
    match '/stores/:id/history'                     => 'stores#revisions'
  end
end
