class Product < Sequel::Model

  plugin :timestamps, :update_on_create => true
  plugin :archive, :crawl_id => [
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
    :has_value_added_promotion,
    :value_added_promotion_description,
    :has_limited_time_offer,
    :has_bonus_reward_miles]

  many_to_one :crawl
  many_to_many :stores, :join_table => :inventories

  def self.place(attrs)
    id = attrs.delete(:product_no)
    raise ArgumentError, "attrs must contain :product_no" unless id
    attrs[:updated_at] = Time.now.utc
    if 0 == dataset.filter(:id => id).update(attrs)
      attrs[:id] = id
      attrs[:created_at] = attrs[:updated_at]
      dataset.insert(attrs)
    end
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
      except(:id, :is_hidden)
  end

end
