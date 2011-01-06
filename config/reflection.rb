service do
  version 2

  root 'http://lcboapi.com'
  name 'LCBO API'
  desc 'Provides JSON data for LCBO products, stores, and inventories.'

  get '/datasets' do
    name 'Datasets'
  end

  get '/datasets/:dataset_id' do
    name 'Dataset'
  end

  get '/products' do
    name 'Products'
  end

  get '/products/:product_id' do
    name 'Product'

    arg :product_id do
      desc 'A product ID'
    end
  end

  get '/products/:product_id/inventories' do
    name 'Product Inventories'
  end

  get '/products/:product_id/history' do
    name 'Product History'
  end

  get '/products/:product_id/history' do
    name 'Product History'
  end

  get '/products/:product_id/stores' do
    name 'Stores with Product'
  end

  get '/stores' do
    name 'Stores'
  end

  get '/stores/:store_id' do
    name 'Store'
  end

  get '/stores/:store_id/history' do
    name 'Store History'
  end

  get '/stores/:store_id/products' do
    name 'Products at Store'
  end

  get '/stores/:store_id/products/:product_id/inventory' do
    name 'Store Product Inventory'
  end

  get '/stores/:store_id/products/:product_id/history' do
    name 'Store Product Inventory History'
  end

  get '/inventories' do
    name 'Inventories'
  end
end