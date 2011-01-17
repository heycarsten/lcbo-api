LCBOAPI::Application.routes.draw do

  LATLON_RE = /\-{0,1}[0-9]+\.[0-9]+/

  namespace :admin do
    root :to => 'crawls#index'
    resources :crawls
    resources :crawl_events
  end

  root :to => 'root#index'

  get '/docs(/:slug)' => 'root#show'

  scope :version => 1, :constraints => { :lat => LATLON_RE, :lon => LATLON_RE } do
    get '/download/:year-:month-:day' => 'datasets#deprecated', :name => :dataset_by_date
    get '/download/current' => 'datasets#deprecated', :name => :current_dataset
    get '/products/search' => 'products#index'
    get '/products/:product_id/inventory' => 'inventories#index'
    get '/stores/search' => 'stores#index'
    get '/stores/near/geo(/with/:product_id)' => 'stores#index', :is_geo_q => true
    get '/stores/near/:geo(/with/:product_id)' => 'stores#index'
    get '/stores/near/:lat/:lon(/with/:product_id)' => 'stores#index'
    get '/stores/:store_id/products/search' => 'products#index'
  end

  scope :version => 2 do
    resources :datasets, :only => [:index, :show]

    resources :products, :only => [:index, :show] do
      resources :inventories, :only => [:index], :controller => 'inventories'
      resources :history,     :only => [:index], :controller => 'revisions'
      resources :stores,      :only => [:index]
    end

    resources :stores, :only => [:index, :show] do
      resources :history,  :only => [:index], :controller => 'revisions'
      resources :products, :only => [:index] do
        get 'inventory' => 'inventories#show', :as => :store_inventory
        resources :history, :only => [:index], :controller => 'revisions'
      end
    end

    resources :inventories, :only => [:index]
  end

end
