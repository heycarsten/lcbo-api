class ProductUpdate < Ohm::Model

  include Ohm::Typecast

  attribute :was_discontinued,                    Boolean
  attribute :was_removed,                         Boolean
  attribute :price_in_cents,                      Integer
  attribute :regular_price_in_cents,              Integer
  attribute :limited_time_offer_savings_in_cents, Integer
  attribute :limited_time_offer_ends_on,          String
  attribute :bonus_reward_miles,                  Integer
  attribute :bonus_reward_miles_ends_on,          String
  attribute :inventory_count,                     Integer
  attribute :inventory_price_in_cents,            Integer
  attribute :inventory_volume_in_milliliters,     Integer

end
