class Store < Sequel::Model

  # include Sequel::Archive

  many_to_one  :crawl
  many_to_many :products, :join_table => :inventories

  attr_writer :latitude, :longitude

  # archive :crawl_id, [
  #   :is_hidden,
  #   :products_count,
  #   :inventory_count,
  #   :inventory_price_in_cents,
  #   :inventory_volume_in_milliliters].
  #   concat(Date::DAYNAMES.map { |day|
  #     [:"#{day.downcase}_open", :"#{day.downcase}_close"]
  #   }.flatten)

  def self.place(attrs)
    id = attrs[:store_id] || attrs[:store_no] || attrs[:id]
    if (store = where(:id => id).first)
      store.update_attributes(attrs)
    else
      create(attrs)
    end
  end

  def before_save
    super
    set_geometry
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

  def set_geometry
    return true unless @latitude && @longitude
    self.geo = GeoRuby::SimpleFeatures::Point.from_x_y(@latitude, @longitude, 4326)
  end


end
