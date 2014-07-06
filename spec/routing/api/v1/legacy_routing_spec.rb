require 'spec_helper'

describe 'V1 Legacy routing' do
  it 'routes /products/:product_no' do
    expect(get '/products/18').to route_to(
      api_version: 1,
      controller: 'api/v1/products',
      action:     'show',
      id:        '18')
  end

  it 'routes /products/search' do
    expect(get '/products/search').to route_to(
      api_version: 1,
      controller: 'api/v1/products',
      action:     'index')
  end

  it 'routes /stores/:store_no' do
    expect(get '/stores/511').to route_to(
      api_version: 1,
      controller: 'api/v1/stores',
      action:     'show',
      id:        '511')
  end

  it 'routes /stores/search' do
    expect(get '/stores/search').to route_to(
      api_version: 1,
      controller: 'api/v1/stores',
      action:     'index')
  end

  it 'routes /stores/:store_no/products/search' do
    expect(get '/stores/511/products/search').to route_to(
      api_version: 1,
      controller: 'api/v1/products',
      action:     'index',
      store_id:   '511')
  end

  it 'routes /products/:product_no/inventory' do
    expect(get '/products/18/inventory').to route_to(
      api_version: 1,
      controller: 'api/v1/inventories',
      action:     'index',
      product_id: '18')
  end

  it 'routes /stores/:store_no/products/:product_no/inventory' do
    expect(get '/stores/511/products/18/inventory').to route_to(
      api_version: 1,
      controller: 'api/v1/inventories',
      action:     'show',
      store_id:   '511',
      product_id: '18')
  end

  it 'routes /stores/near/:latitude/:longitude' do
    expect(get '/stores/near/43.0/-78.0').to route_to(
      api_version: 1,
      controller: 'api/v1/stores',
      action:     'index',
      lat:        '43.0',
      lon:        '-78.0')
  end

  it 'routes /stores/near/:postal_code' do
    expect(get '/stores/near/m6r3a1').to route_to(
      api_version: 1,
      controller: 'api/v1/stores',
      action:     'index',
      geo:        'm6r3a1')
  end

  it 'routes /stores/near/geo?q=:uri_encoded_query' do
    expect(get '/stores/near/geo').to route_to(
      api_version: 1,
      controller: 'api/v1/stores',
      action:     'index',
      is_geo_q:   true)
  end

  it 'routes /stores/near/:latitude/:longitude/with/:product_no' do
    expect(get '/stores/near/43.0/-78.0/with/18').to route_to(
      api_version: 1,
      controller: 'api/v1/stores',
      action:     'index',
      lat:        '43.0',
      lon:        '-78.0',
      product_id: '18')
  end

  it 'routes /stores/near/:postal_code/with/:product_no' do
    expect(get '/stores/near/m6r3a1/with/18').to route_to(
      api_version: 1,
      controller: 'api/v1/stores',
      action:     'index',
      geo:        'm6r3a1',
      product_id: '18')
  end

  it 'routes /stores/near/geo/with/:product_no?q=:uri_encoded_query' do
    expect(get '/stores/near/geo/with/18').to route_to(
      api_version: 1,
      controller: 'api/v1/stores',
      action:     'index',
      product_id: '18',
      is_geo_q:   true)
  end

  it 'routes /download/current.zip' do
    expect(get '/download/current.zip').to route_to(
      api_version: 1,
      name:       :current_dataset,
      controller: 'api/v1/root',
      action:     'deprecated',
      format:     'zip')
  end

  it 'routes /download/:year-:month-:day.zip' do
    expect(get '/download/2010-10-10.zip').to route_to(
      api_version: 1,
      name:       :dataset_by_date,
      controller: 'api/v1/root',
      action:     'deprecated',
      year:       '2010',
      month:      '10',
      day:        '10',
      format:     'zip')
  end
end
