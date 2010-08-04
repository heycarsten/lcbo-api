Fabricator(:crawl) do
  timestamp { Fabricate.sequence(:crawl_timestamp, 1) }
end

Fabricator(:product) do
  product_no { Fabricate.sequence(:product_no, 1) }
  crawl_timestamp 1
  name 'Test Product'
end

Fabricator(:store) do
  store_no { Fabricate.sequence(:store_no, 1) }
  crawl_timestamp 1
  latitude 43.6417
  longitude -79.4324
  geo [-79.4324, 43.6417]
end

Fabricator(:inventory) do
  crawl_timestamp 1
  product_no 1
  store_no 1
end
