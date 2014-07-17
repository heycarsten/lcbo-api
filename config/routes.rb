Rails.application.routes.draw do
  namespace :admin do
    root to: 'crawls#index'
    resources :crawls
    resources :crawl_events
  end

  controller :root, action: :ember do
    get '/register'
    get '/account'
    get '/verify/:token',   as: :verification
    get '/password/:token', as: :password
    get '/manage'
    get '/manage/keys/new'
    get '/manage/keys/:key_id'
    get '/log-in'
  end

  namespace :api, path: '/', format: :json do
    namespace :v2, path: '(v2)', constraints: APIConstraint.new(2) do
      namespace :manager do
        controller :accounts do
          get    '/account'  => :show,   as: :account
          patch  '/account'  => :update
          delete '/account'  => :destroy
          post   '/accounts' => :create, as: :accounts
        end

        controller :verifications do
          put '/verifications/:token' => :update
        end

        controller :passwords do
          post '/passwords'        => :create
          put  '/passwords/:token' => :update
        end

        controller :sessions do
          get    '/session'  => :show,    as: :session
          delete '/session'  => :destroy
          put    '/session'  => :update
          post   '/sessions' => :create,  as: :sessions
        end

        controller :keys do
          get    '/keys'     => :index,  as: :keys
          post   '/keys'     => :create
          get    '/keys/:id' => :show,   as: :key
          patch  '/keys/:id' => :update
          delete '/keys/:id' => :destroy
        end
      end

      controller :datasets do
        get '/datasets'     => :index, as: :datasets
        get '/datasets/:id' => :show,  as: :dataset
      end

      controller :inventories do
        get '/inventories' => :index, as: :inventories
        get '/stores/:store_id/products/:product_id/inventory' => :show, as: :inventory
      end

      controller :products do
        get '/products'     => :index, as: :products
        get '/products/:id' => :show,  as: :product
      end

      controller :stores do
        get '/stores'     => :index, as: :stores
        get '/stores/:id' => :show,  as: :store
      end
    end

    scope module: :v1, path: '(v1)', constraints: APIConstraint.new(1, true) do
      # Legacy V1
      scope constraints: { lat: GeoScope::LATLON_RE, lon: GeoScope::LATLON_RE } do
        get '/download/:year-:month-:day'               => 'root#deprecated', name: :dataset_by_date
        get '/download/current'                         => 'root#deprecated', name: :current_dataset
        get '/products/search'                          => 'products#index'
        get '/products/:product_id/inventory'           => 'inventories#index'
        get '/stores/search'                            => 'stores#index'
        get '/stores/near/geo(/with/:product_id)'       => 'stores#index',    is_geo_q: true
        get '/stores/near/:geo(/with/:product_id)'      => 'stores#index'
        get '/stores/near/:lat/:lon(/with/:product_id)' => 'stores#index'
        get '/stores/:store_id/products/search'         => 'products#index'
      end

      resources :datasets, only: [:index, :show]

      resources :products, only: [:index, :show] do
        resources :inventories, only: [:index], controller: 'inventories'
        resources :stores,      only: [:index]
      end

      resources :stores, only: [:index, :show] do
        resources :products, only: [:index] do
          get 'inventory' => 'inventories#show', as: :store_inventory
        end
      end

      resources :inventories, only: [:index]

      get '/stores/:id/history'                            => 'root#deprecated', name: :store_history
      get '/products/:id/history'                          => 'root#deprecated', name: :product_history
      get '/stores/:store_id/products/:product_id/history' => 'root#deprecated', name: :inventory_history
    end
  end
end
