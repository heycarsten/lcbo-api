class Factory
  def self.factories
    @factories ||= {}
  end

  def self.define(model, &block)
    factories[model] = begin
      factory = new
      factory.instance_eval(&block)
      factory
    end
  end

  def self.build(model, overloads = {})
    factory = factories[model]
    raise ArgumentError, "There is no factory for #{model} yet." unless factory
    model.new(factory.defaults.merge(overloads))
  end

  def self.create(model, overloads = {})
    instance = build(model, overloads)
    instance.save
    instance
  end

  attr_reader :defaults

  def initialize
    @defaults = {}
  end

  def method_missing(name, value)
    defaults[name] = value
  end
end

def Factory(*args)
  Factory.create(*args)
end

Factory.define(Crawl) do
  
end

Factory.define(Product) do
  product_no                          1
  name                                'Floris Ninkeberry Gardenbeer'
  price_in_cents                      250
  regular_price_in_cents              250
  limited_time_offer_savings_in_cents 0
  limited_time_offer_ends_on          nil
  bonus_reward_miles                  nil
  bonus_reward_miles_ends_on          nil
  alcohol_content                     350
  sugar_content                       '8'
  package                             '330 mL bottle'
  package_unit_type                   'bottle'
  package_unit_volume_in_milliliters  330
  total_package_units                 1
  total_package_volume_in_milliliters 330
  inventory_count                     1000
  inventory_volume_in_milliliters     330000
  inventory_price_in_cents            25000
  origin                              'Belgium'
  producer_name                       'Brouwerij Huyghe'
  released_on                         '2010-10-10'
  stock_type                          'LCBO'
  primary_category                    'Beer'
  secondary_category                  'Ale'
  has_bonus_reward_miles              false
  has_limited_time_offer              false
  is_vqa                              false
  is_discontinued                     true
  is_seasonal                         false
  description                         'A beer that is a beerish color'
  tasting_note                        'Tastes like beer'
  serving_suggestion                  'Serve chilled'
end

Factory.define(Store) do
  store_no                        1
  name                            'Street & Avenue'
  address_line_1                  '2356 Kennedy Road'
  address_line_2                  'Agincourt Mall'
  city                            'Toronto-Scarborough'
  postal_code                     'M1T3H1'
  telephone                       '(416) 291-5304'
  fax                             '(416) 291-0246'
  latitude                        43.7838
  longitude                       -79.2902
  has_parking                     true
  has_transit_access              true
  has_wheelchair_accessability    true
  has_bilingual_services          false
  has_product_consultant          false
  has_tasting_bar                 true
  has_beer_cold_room              false
  has_special_occasion_permits    true
  has_vintages_corner             true
  monday_open                     600
  monday_close                    1320
  tuesday_open                    600
  tuesday_close                   1320
  wednesday_open                  600
  wednesday_close                 1320
  thursday_open                   600
  thursday_close                  1320
  friday_open                     600
  friday_close                    1320
  saturday_open                   600
  saturday_close                  1320
  sunday_open                     720
  sunday_close                    1020
  products_count                  50
  inventory_count                 1000
  inventory_price_in_cents        1000000
  inventory_volume_in_milliliters 1000000
end

Factory.define(Inventory) do
  product_no 1
  store_no   1
  quality    100
end
