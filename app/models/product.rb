class Product < ActiveRecord::Base

  belongs_to :crawl

  archive :crawl_id, [
    :is_hidden,
    :is_discontinued,
    :price_in_cents,
    :regular_price_in_cents,
    :limited_time_offer_savings_in_cents,
    :limited_time_offer_ends_on,
    :bonus_reward_miles,
    :bonus_reward_miles_ends_on,
    :inventory_count,
    :inventory_volume_in_milliliters,
    :inventory_price_in_cents,
    :has_limited_time_offer,
    :has_bonus_reward_miles]

  def self.place(attrs)
    id = attrs[:product_no] || attrs[:product_id] || attrs[:id]
    (product = find(id)) ? product.update_attributes(attrs) : create(attrs)
  end

  def product_no=(value)
    self.id = value
  end

  def product_no
    id
  end

  def as_json
    { :product_no => product_no }.
      merge(super).
      exclude(:id, :is_hidden)
  end

end
