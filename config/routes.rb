Rails.application.routes.draw do
  LATLON_RE = /\-{0,1}[0-9]+\.[0-9]+/

  namespace :admin do
    root to: 'crawls#index'
    resources :crawls
    resources :crawl_events
  end

  root to: 'root#show'

  namespace :api, path: '/' do
    namespace :v1, path: '(v1)' do
      scope version: 1, constraints: { lat: LATLON_RE, lon: LATLON_RE } do
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

      scope version: 2 do
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
end
