# == Schema Information
#
# Table name: stores
#
#  id                              :integer         not null, primary key
#  crawl_id                        :integer
#  is_hidden                       :boolean         default(FALSE)
#  name                            :string(50)
#  address_line_1                  :string(40)
#  address_line_2                  :string(40)
#  city                            :string(25)
#  postal_code                     :string(6)
#  telephone                       :string(14)
#  fax                             :string(14)
#  products_count                  :integer         default(0)
#  inventory_count                 :integer         default(0)
#  inventory_price_in_cents        :integer         default(0)
#  inventory_volume_in_milliliters :integer         default(0)
#  has_wheelchair_accessability    :boolean         default(FALSE)
#  has_bilingual_services          :boolean         default(FALSE)
#  has_product_consultant          :boolean         default(FALSE)
#  has_tasting_bar                 :boolean         default(FALSE)
#  has_beer_cold_room              :boolean         default(FALSE)
#  has_special_occasion_permits    :boolean         default(FALSE)
#  has_vintages_corner             :boolean         default(FALSE)
#  has_parking                     :boolean         default(FALSE)
#  has_transit_access              :boolean         default(FALSE)
#  sunday_open                     :integer
#  sunday_close                    :integer
#  monday_open                     :integer
#  monday_close                    :integer
#  tuesday_open                    :integer
#  tuesday_close                   :integer
#  wednesday_open                  :integer
#  wednesday_close                 :integer
#  thursday_open                   :integer
#  thursday_close                  :integer
#  friday_open                     :integer
#  friday_close                    :integer
#  saturday_open                   :integer
#  saturday_close                  :integer
#  created_at                      :datetime
#  updated_at                      :datetime
#  geo                             :string          not null, point, 4326
#
# Indexes
#
#  index_stores_on_crawl_id   (crawl_id)
#  index_stores_on_geo        (geo)
#  index_stores_on_is_hidden  (is_hidden)
#

class Store < ActiveRecord::Base

  include ActiveRecord::Archive

  belongs_to :crawl

  attr_writer :latitude, :longitude

  archive :crawl_id, [
    :is_hidden,
    :products_count,
    :inventory_count,
    :inventory_price_in_cents,
    :inventory_volume_in_milliliters].concat(
      Date::DAYNAMES.map do |day|
        [:"#{day.downcase}_open", :"#{day.downcase}_close"]
      end.flatten)

  before_validation :set_geo

  def self.place(attrs)
    id = attrs[:store_id] || attrs[:store_no] || attrs[:id]
    if (store = where(:id => id).first)
      store.update_attributes(attrs)
    else
      create(attrs)
    end
  end

  def store_no=(value)
    self.id = value
  end

  def store_no
    id
  end

  def latitude
    geo.x
  end

  def longitude
    geo.y
  end

  def as_json
    { :store_no => store_no,
      :latitude => latitude,
      :longitude => longitude }.
      merge(super).
      exclude(:id, :is_hidden)
  end

  protected

  def set_geo
    self.geo = Point.from_x_y(@latitude, @longitude, 4326)
  end

end

