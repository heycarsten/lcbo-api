many_id_re = /([a-z0-9\-]+\,[a-z0-9\-]+\,{0,1})+/

Rails.application.routes.draw do
  namespace :api, path: '/', format: :json do
    namespace :v2, path: '(v2)', constraints: APIConstraint.new(2) do
      namespace :manager do
        controller :accounts do
          get    '/account'  => :show,   as: :account
          put    '/account'  => :update
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
          put    '/keys/:id' => :update
          delete '/keys/:id' => :destroy
        end
      end

      match '*path', to: 'api#preflight_cors', via: :options

      controller :datasets do
        get '/datasets'     => :index, as: :datasets
        get '/datasets/:id' => :index, constraints: { id: many_id_re }
        get '/datasets/:id' => :show,  as: :dataset
      end

      controller :inventories do
        get '/inventories'     => :index, as: :inventories
        get '/inventories/:id' => :index, constraints: { id: many_id_re }
        get '/inventories/:id' => :show, as: :inventory
        get '/products/:product_id/stores/:store_id' => redirect('/inventories/%{product_id}-%{store_id}')
        get '/stores/:store_id/products/:product_id' => redirect('/inventories/%{product_id}-%{store_id}')
      end

      controller :products do
        get '/products'     => :index, as: :products
        get '/products/:id' => :index, constraints: { id: many_id_re }
        get '/products/:id' => :show,  as: :product
      end

      controller :stores do
        get '/stores'     => :index, as: :stores
        get '/stores/:id' => :index, constraints: { id: many_id_re }
        get '/stores/:id' => :show,  as: :store
      end

      controller :producers do
        get '/producers'     => :index, as: :producers
        get '/producers/:id' => :index, constraints: { id: many_id_re }
        get '/producers/:id' => :show,  as: :producer
      end

      controller :categories do
        get '/categories'     => :index, as: :categories
        get '/categories/:id' => :index, constraints: { id: many_id_re }
        get '/categories/:id' => :show,  as: :category
      end
    end

    scope module: :v1, path: '(v1)', constraints: APIConstraint.new(1, true) do
      match '*path', to: 'api#preflight_cors', via: :options

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

  controller :root, action: :ember, format: :html do
    get '/sign-up'      => redirect('/manager/sign-up')
    get '/log-in'       => redirect('/manager/log-in')
    get '/manage'       => redirect('/manager')
    get '/manage/*path' => redirect('/manager/%{path}')
    get '/manager'
    get '/manager/log-in'
    get '/manager/sign-up'
    get '/manager/verify/:token',   as: :verify_token
    get '/manager/password/recover'
    get '/manager/password/:token', as: :password
    get '/manager/account'
    get '/manager/keys'
    get '/manager/keys/new'
    get '/manager/keys/:key_id'
    get '/manager/credits'
    get '/manager/terms'
    get '/manager/privacy'
  end

  namespace :admin do
    root to: 'crawls#index'

    resources :crawls
    resources :crawl_events
    resources :users

    resources :plans do
      member do
        put :clone
      end
    end
  end
end
