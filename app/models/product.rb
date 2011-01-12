class Product < Sequel::Model

  unrestrict_primary_key

  plugin :timestamps, :update_on_create => true
  plugin :archive, :crawl_id
  plugin :csv

  many_to_one :crawl
  one_to_many :inventories

  PRIVATE_FIELDS = [:created_at, :crawl_id, :store_id, :product_id,
    :total_package_volume_in_milliliters]

  def self.public_fields
    @public_fields ||= (columns - PRIVATE_FIELDS)
  end

  def self.as_json(hsh)
    hsh.
      except(*PRIVATE_FIELDS).
      merge(:product_no => hsh[:id])
  end

  def self.place(attrs)
    attrs[:updated_at] = Time.now.utc
    attrs[:tags] = attrs[:tags].any? ? attrs[:tags].join(' ') : nil
    if 0 == dataset.filter(:id => attrs[:id]).update(attrs)
      attrs[:created_at] = attrs[:updated_at]
      dataset.insert(attrs)
    end
  end

  def as_json
    self.class.as_json(super['values'])
  end

end
