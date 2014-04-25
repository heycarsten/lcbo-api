class Product < Sequel::Model

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

  unrestrict_primary_key

  plugin :timestamps, update_on_create: true
  plugin :api,
    private: [
      :created_at,
      :crawl_id,
      :store_id,
      :product_id,
      :total_package_volume_in_milliliters
    ],
    aliases: { id: :product_no }

  many_to_one :crawl
  one_to_many :inventories

  def self.place(attrs)
    attrs[:updated_at] = Time.now.utc
    attrs[:tags]       = attrs[:tags].any? ? attrs[:tags].join(' ') : nil
    attrs[:is_dead]    = false
    attrs[:city]       = SIMPLIFIED_CITIES[attrs[:city]] || attrs[:city]
    if 0 == dataset.where(id: attrs[:id]).update(attrs)
      attrs[:created_at] = attrs[:updated_at]
      dataset.insert(attrs)
    end
  end

end
