class Store < Sequel::Model

  unrestrict_primary_key

  plugin :timestamps, :update_on_create => true
  plugin :geo
  plugin :archive, :crawl_id

  many_to_one :crawl
  one_to_many :inventories

  def self.as_json(hsh)
    hsh.
      merge(:store_no => hsh[:id]).
      except(:id, :latrad, :lngrad, :created_at, :updated_at, :crawl_id)
  end

  def self.place(attrs)
    id = attrs[:store_no]
    raise ArgumentError, "attrs must contain :store_no" unless id
    attrs[:tags] = attrs[:tags].any? ? attrs[:tags].join(' ') : nil
    (store = self[id]) ? store.update(attrs) : create(attrs)
  end

  def self.distance_from_with_product(lat, lon, product_id)
    distance_from(lat, lon).
      join(:inventories, :store_id => :id).
      filter('inventories.quantity > 0').
      filter(:inventories__product_id => product_id)
  end

  def store_no=(value)
    self.id = value
  end

  def store_no
    id
  end

  def as_json
    self.class.as_json(super['values'])
  end

  def before_save
    super
    self.latrad = (self.latitude  * (Math::PI / 180.0))
    self.lngrad = (self.longitude * (Math::PI / 180.0))
  end

end
