class Store < Sequel::Model

  plugin :timestamps, :update_on_create => true
  plugin :archive, :crawl_id => [
    :is_hidden,
    :products_count,
    :inventory_count,
    :inventory_price_in_cents,
    :inventory_volume_in_milliliters].
    concat(Date::DAYNAMES.map { |day|
      [:"#{day.downcase}_open", :"#{day.downcase}_close"]
    }.flatten)

  many_to_one :crawl
  one_to_many :inventories

  def self.place(attrs)
    id = attrs[:store_no]
    raise ArgumentError, "attrs must contain :store_no" unless id
    (store = self[id]) ? store.update(attrs) : create(attrs)
  end

  def store_no=(value)
    self.id = value
  end

  def store_no
    id
  end

  def as_json
    { :store_no => id }.
      merge(super['values']).
      except(:id, :is_hidden, :latrad, :lngrad, :created_at, :updated_at, :crawl_id)
  end

  def before_save
    super
    self.latrad = (self.latitude  * (Math::PI / 180.0))
    self.lngrad = (self.longitude * (Math::PI / 180.0))
  end

end
