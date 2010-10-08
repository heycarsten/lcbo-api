class Product < Ohm::Model

  include Ohm::Typecast
  include Ohm::Callbacks
  include Ohm::Archive

  attribute :crawled_at,                          Time
  attribute :is_hidden,                           Boolean

  attribute :product_no,                          Integer
  attribute :name,                                String
  attribute :is_discontinued,                     Boolean
  attribute :price_in_cents,                      Integer
  attribute :regular_price_in_cents,              Integer
  attribute :limited_time_offer_savings_in_cents, Integer
  attribute :limited_time_offer_ends_on,          String
  attribute :bonus_reward_miles,                  Integer
  attribute :bonus_reward_miles_ends_on,          String
  attribute :stock_type,                          String
  attribute :primary_category,                    String
  attribute :secondary_category,                  String
  attribute :origin,                              String
  attribute :package,                             String
  attribute :package_unit_type,                   String
  attribute :package_unit_volume_in_milliliters,  Integer
  attribute :total_package_units,                 Integer
  attribute :total_package_volume_in_milliliters, Integer
  attribute :volume_in_milliliters,               Integer
  attribute :alcohol_content,                     Integer
  attribute :inventory_count,                     Integer
  attribute :inventory_volume_in_milliliters,     Integer
  attribute :inventory_price_in_cents,            Integer
  attribute :sugar_content,                       String
  attribute :producer_name,                       String
  attribute :released_on,                         String
  attribute :has_limited_time_offer,              Boolean
  attribute :has_bonus_reward_miles,              Boolean
  attribute :is_seasonal,                         Boolean
  attribute :is_vqa,                              Boolean
  attribute :description,                         String
  attribute :serving_suggestion,                  String
  attribute :tasting_note,                        String

  index :product_no
  index :crawled_at

  archive :crawled_at, [
    :is_discontinued,
    :price_in_cents,
    :regular_price_in_cents,
    :limited_time_offer_savings_in_cents,
    :limited_time_offer_ends_on,
    :bonus_reward_miles,
    :bonus_reward_miles_ends_on,
    :inventory_count,
    :inventory_price_in_cents,
    :inventory_volume_in_milliliters]

end
