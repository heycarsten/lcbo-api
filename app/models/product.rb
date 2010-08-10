class Product

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Archive

  key :product_no

  field :is_active,             :type => Boolean, :default => true
  field :crawl_timestamp,       :type => Integer
  field :inventory_updated_at,  :type => DateTime
  field :was_crawled,           :type => Boolean, :default => false
  field :was_discontinued,      :type => Boolean, :default => false
  field :was_removed,           :type => Boolean, :default => false

  # Public fields
  field :product_no,                          :type => Integer
  field :name
  field :price_in_cents,                      :type => Integer
  field :regular_price_in_cents,              :type => Integer
  field :limited_time_offer_savings_in_cents, :type => Integer
  field :limited_time_offer_ends_on,          :type => Date
  field :bonus_reward_miles,                  :type => Integer
  field :bonus_reward_miles_ends_on,          :type => Date
  field :stock_type
  field :primary_category
  field :secondary_category
  field :origin
  field :package
  field :package_unit_type
  field :package_unit_volume_in_milliliters,  :type => Integer, :default => 0
  field :total_package_units,                 :type => Integer, :default => 0
  field :total_package_volume_in_milliliters, :type => Integer, :default => 0
  field :volume_in_milliliters,               :type => Integer, :default => 0
  field :alcohol_content,                     :type => Integer, :default => 0
  field :inventory_count,                     :type => Integer, :default => 0
  field :inventory_volume_in_milliliters,     :type => Integer, :default => 0
  field :inventory_price_in_cents,            :type => Integer, :default => 0
  field :sugar_content
  field :producer_name
  field :released_on,                         :type => Date
  field :is_discontinued,                     :type => Boolean
  field :has_limited_time_offer,              :type => Boolean
  field :has_bonus_reward_miles,              :type => Boolean
  field :is_seasonal,                         :type => Boolean
  field :is_vqa,                              :type => Boolean
  field :description
  field :serving_suggestion
  field :tasting_note

  index [[:inventory_updated_at, Mongo::ASCENDING]]
  index [[:updated_at, Mongo::ASCENDING]]
  index [[:product_no, Mongo::ASCENDING]], :unique => true
  index [[:crawl_timestamp, Mongo::ASCENDING]]
  index [[:inventory_count, Mongo::DESCENDING]]
  index [[:inventory_volume_in_milliliters, Mongo::ASCENDING]]

  archive :crawl_timestamp, [
    :is_active,
    :was_discontinued,
    :was_removed,
    :price_in_cents,
    :regular_price_in_cents,
    :limited_time_offer_savings_in_cents,
    :limited_time_offer_ends_on,
    :bonus_reward_miles,
    :bonus_reward_miles_ends_on,
    :inventory_count,
    :inventory_price_in_cents,
    :inventory_volume_in_milliliters]

  scope :crawlable, lambda {
    where(:updated_at.lt => 12.hours.ago).
    or(:was_crawled => false).
    order_by(:inventory_updated_at.asc) }

  scope :needing_inventory_update, lambda {
    where(:inventory_updated_at.lt => 12.hours.ago).
    order_by(:inventory_updated_at.asc) }

  after_save do |product|
    product.inventories.update(:is_active => false) if !product.is_active
  end

  def commit_inventory(crawl, params)
    
  end

end
