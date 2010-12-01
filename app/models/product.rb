class Product < ActiveRecord::Model

  include ActiveRecord::Archive

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
