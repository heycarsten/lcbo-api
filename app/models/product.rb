class Product < Sequel::Model

  unrestrict_primary_key

  plugin :timestamps, :update_on_create => true
  plugin :archive, :crawl_id

  many_to_one :crawl
  one_to_many :inventories

  def self.as_json(hsh)
    hsh.
      merge(:product_no => hsh[:id]).
      except(:id, :created_at, :updated_at, :crawl_id, :store_id, :product_id)
  end

  def self.place(attrs)
    id = attrs.delete(:product_no)
    raise ArgumentError, "attrs must contain :product_no" unless id
    attrs[:updated_at] = Time.now.utc
    attrs[:tags] = attrs[:tags].any? ? attrs[:tags].join(' ') : nil
    if 0 == dataset.filter(:id => id).update(attrs)
      attrs[:id] = id
      attrs[:created_at] = attrs[:updated_at]
      dataset.insert(attrs)
    end
  end

  def product_no=(value)
    self.id = value
  end

  def product_no
    id
  end

  def as_json
    self.class.as_json(super['values'])
  end

end
