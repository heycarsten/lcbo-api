LCBOAPI::Application.routes.draw do

  namespace :admin do
    root :to => 'crawls#index'
    resources :crawls
    resources :crawl_events
  end

  get '/docs(/:slug)' => 'documents#show', :as => :document
  get '/reflect' => 'reflection#show', :as => :reflection

  scope :version => 1 do
    get '/download/:filename' => 'datasets#depricated'
    get '/download/current' => 'datasets#depricated'
    get '/stores/:store_id/products/search' => 'products#index'
    get '/products/search' => 'products#index'
    get '/stores/near/geo(/with/:product_id)' => 'stores#index', :is_geo_q => true
    get '/stores/near/:lat/:lon/with/:product_id' => 'stores#index'
    get '/stores/near/:geo/with/:product_id' => 'stores#index'
    get '/stores/near/:lat/:lon' => 'stores#index'
    get '/stores/near/:geo' => 'stores#index'
    get '/stores/search' => 'stores#index'
  end

  scope :version => 2 do
    resources :datasets, :only => [:index, :show]

    resources :products, :only => [:index, :show] do
      resources :inventory, :only => [:index], :controller => 'inventories'
      resources :history,   :only => [:index], :controller => 'revisions'
      resources :stores,    :only => [:index]
    end

    resources :stores, :only => [:index, :show] do
      resources :history,  :only => [:index], :controller => 'revisions'
      resources :products, :only => [:index] do
        resources :inventory, :only => [:index], :controller => 'inventories'
        resources :history,   :only => [:index], :controller => 'revisions'
      end
    end
  end

end
