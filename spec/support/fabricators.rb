Fabricator(:crawl) do
  timestamp { Fabricate.sequence(:timestamp, 1) }
end

Fabricator(:product) do
  product_no { Fabricate.sequence(:product_no, 1) }
  timestamp  1
  name       'Test Product'
end

Fabricator(:store) do
  store_no { Fabricate.sequence(:store_no, 1) }
  timestamp                    1
  name                         'Street & Avenue'
  address_line_1               '2356 Kennedy Road'
  address_line_2               'Agincourt Mall'
  city                         'Toronto-Scarborough'
  postal_code                  'M1T3H1'
  telephone                    '(416) 291-5304'
  fax                          '(416) 291-0246'
  latitude                     43.7838
  longitude                    -79.2902
  has_parking                  true
  has_transit_access           true
  has_wheelchair_accessability true
  has_bilingual_services       false
  has_product_consultant       false
  has_tasting_bar              true
  has_beer_cold_room           false
  has_special_occasion_permits true
  has_vintages_corner          true
  monday_open                  600
  monday_close                 1320
  tuesday_open                 600
  tuesday_close                1320
  wednesday_open               600
  wednesday_close              1320
  thursday_open                600
  thursday_close               1320
  friday_open                  600
  friday_close                 1320
  saturday_open                600
  saturday_close               1320
  sunday_open                  720
  sunday_close                 1020
end

Fabricator(:inventory) do
  timestamp  1
  product_no 1
  store_no   1
  quality    100
end
