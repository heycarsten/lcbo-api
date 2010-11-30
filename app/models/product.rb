class Product < Ohm::Model

  include Ohm::Typecast
  include Ohm::Archive
  include Ohm::ToHash
  include Ohm::CountAll
  include Ohm::Sunspot
  include Ohm::Rails

  attribute :crawled_at,                          Time
  attribute :is_hidden,                           Boolean
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

  sunspot do
    text :name
    text :origin
    text :producer_name
    string :package_unit_type
    boolean :is_hidden
    boolean :is_discontinued
    boolean :has_limited_time_offer
    boolean :has_bonus_reward_miles
    boolean :is_seasonal
    boolean :is_vqa
    integer :price_in_cents
    integer :inventory_count
    integer :inventory_volume_in_milliliters
  end

  def self.place(attrs)
    if (product = self[attrs[:product_no]])
      product.update(attrs)
    else
      create(attrs)
    end
  end

  def product_no=(value)
    self.id = value
  end

  def product_no
    id.to_i
  end

  def as_json
    { :product_no => product_no }.merge(to_hash(:id, :is_hidden))
  end

end
