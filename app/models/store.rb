class Store < ApplicationRecord
  include PgSearch
  include GeoScope

  SIMPLIFIED_NAMES = {
    'Victoria Street & Parry Sound' => 'Rosseau'
  }

  CORRECTED_ADDRESSES = {
    '16 Post Street' => '16 Ottawa Street'
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

  belongs_to :crawl, optional: true
  has_many :inventories

  before_save :set_latlonrad

  scope :with_product_ids, ->(*raw_ids) {
    ids      = raw_ids.flatten.map(&:to_i)
    ids_size = ids.size

    select(
      'stores.*, ' \
      "ARRAY[#{ids.join(', ')}] AS inventory_product_ids, " \
      'array_agg(inventories.quantity) AS inventory_quantities, ' \
      'array_agg(inventories.reported_on) AS inventories_reported_on, ' \
      'array_agg(inventories.updated_at) AS inventories_updated_at').
    joins('INNER JOIN inventories ON (stores.id = inventories.store_id)').
    where('inventories.product_id IN (?) AND inventories.quantity != 0', ids).
    group('stores.id').
    having('array_length(array_agg(inventories.quantity), 1) = ?', ids_size)
  }

  scope :with_product_id, ->(raw_id) {
    id = raw_id.to_i
    joins(:inventories).
    select(
      'stores.*, ' \
      "#{id} AS inventory_product_id, " \
      'inventories.quantity AS inventory_quantity, ' \
      'inventories.reported_on AS inventory_reported_on, ' \
      'inventories.updated_at AS inventory_updated_at').
    where('inventories.quantity > 0 AND inventories.product_id = ?', id)
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
    attrs[:address_line_1] = CORRECTED_ADDRESSES[attrs[:address_line_1]] || attrs[:address_line_1]

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
