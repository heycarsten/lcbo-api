class Product < ActiveRecord::Base
  include PgSearch

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

  pg_search_scope :search,
    against:  :tags,
    ignoring: :accents,
    using: {
      tsearch: { prefix: true }
    }

  belongs_to :crawl
  has_many :inventories

  def self.place(attrs)
    attrs[:updated_at] = Time.now.utc
    attrs[:tags]       = attrs[:tags].any? ? attrs[:tags].join(' ') : nil
    attrs[:is_dead]    = false
    attrs[:city]       = SIMPLIFIED_CITIES[attrs[:city]] || attrs[:city]

    if 0 == where(id: attrs[:id]).update_all(attrs)
      create!(attrs)
    end
  end
end
