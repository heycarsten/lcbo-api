class Store < ActiveRecord::Base
  include PgSearch
  include GeoScope

  SIMPLIFIED_NAMES = {
    'Victoria Street & Parry Sound' => 'Rosseau'
  }

  SIMPLIFIED_CITIES = {
    'Cambridge-Preston'   => 'Preston',
    'Ottawa-Gloucester'   => 'Gloucester',
    'Ottawa-Kanata'       => 'Kanata',
    'Ottawa-Nepean'       => 'Nepean',
    'Ottawa-Orleans'      => 'Orleans',
    'Ottawa-Vanier'       => 'Vanier',
    'Sudbury-Downtown'    => 'Sudbury',
    'Sudbury-New Sudbury' => 'New Sudbury',
    'Sudbury-South End'   => 'Sudbury (South End)',
    'Toronto-Central'     => 'Toronto',
    'Toronto-Etobicoke'   => 'Etobicoke',
    'Toronto-North York'  => 'North York',
    'Toronto-Scarborough' => 'Scarborough'
  }

  belongs_to :crawl
  has_many :inventories

  before_save :set_latlonrad

  scope :distance_from_with_product, ->(lat, lon, product_id) {
    distance_from(lat, lon).
      joins(:inventories).
      select('stores.*, inventories.quantity, inventories.updated_on').
      where('inventories.quantity > 0').
      where('inventories.product_id' => product_id)
  }

  pg_search_scope :search,
    against:  :tags,
    ignoring: :accents,
    using: {
      tsearch: { prefix: true }
    }

  def self.place(attrs)
    id = attrs[:id]

    raise ArgumentError, "attrs must contain :id" unless id

    attrs[:is_dead] = false
    attrs[:tags] = attrs[:tags].any? ? attrs[:tags].join(' ') : nil
    attrs[:city] = SIMPLIFIED_CITIES[attrs[:city]] || attrs[:city]
    attrs[:name] = SIMPLIFIED_NAMES[attrs[:name]] || attrs[:name]

    if (store = where(id: id).first)
      store.update!(attrs)
    else
      create!(attrs)
    end
  end

  def set_latlonrad
    self.latrad = (self.latitude  * (Math::PI / 180.0))
    self.lngrad = (self.longitude * (Math::PI / 180.0))
    true
  end
end
