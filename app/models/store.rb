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

  scope :with_product_ids, ->(*raw_ids) {
    ids      = raw_ids.flatten.map(&:to_i)
    ids_size = ids.size

    select(
      'stores.*, ' \
      "ARRAY[#{ids.join(', ')}] AS inventory_product_ids, " \
      'array_agg(inventories.quantity) AS inventory_quantities, ' \
      'array_agg(inventories.reported_on) AS inventories_reported_on').
    joins('LEFT JOIN inventories ON (stores.id = inventories.store_id)').
    where('inventories.product_id IN (?) AND inventories.quantity != 0', ids).
    group('stores.id').
    having('array_length(array_agg(inventories.quantity), 1) = ?', ids_size)
  }

  scope :distance_from_with_product, ->(lat, lon, product_id) {
    distance_from(lat, lon).
      joins(:inventories).
      select('stores.*, inventories.quantity, inventories.reported_on').
      where('inventories.quantity > 0').
      where('inventories.product_id' => product_id)
  }

  pg_search_scope :search,
    against:  :tags,
    ignoring: :accents,
    using: {
      tsearch: {
        prefix: true,
        tsvector_column: :tag_vectors
      }
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
