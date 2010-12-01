class Store < ActiveRecord::Base

  belongs_to :crawl

  archive :crawl_id, [
    :is_hidden,
    :products_count,
    :inventory_count,
    :inventory_price_in_cents,
    :inventory_volume_in_milliliters].concat(
      Date::DAYNAMES.map do |day|
        [:"#{day.downcase}_open", :"#{day.downcase}_close"]
      end.flatten
    )

  def self.place(attrs)
    id = attrs[:store_id] || attrs[:store_no] || attrs[:id]
    (store = find(id)) ? store.update_attributes(attrs) : create(attrs)
  end

  def store_no=(value)
    self.id = value
  end

  def store_no
    id
  end

  def as_json
    { :store_no => store_no }.
      merge(super).
      exclude(:id, :is_hidden)
  end

end
