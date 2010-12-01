class Store < ActiveRecord::Model

  include ActiveRecord::Archive

  archive :crawled_at, [
    :is_hidden,
    :products_count,
    :inventory_count,
    :inventory_price_in_cents,
    :inventory_volume_in_milliliters]

  def self.place(attrs)
    if (store = self[attrs[:store_no]])
      store.update(attrs)
    else
      create(attrs)
    end
  end

  def geo
    Struct.new(:lat, :lng).new(latitude, longitude)
  end

  def store_no=(value)
    self.id = value
  end

  def store_no
    id.to_i
  end

  def as_json
    { :store_no => store_no }.merge(to_hash(:id, :is_hidden))
  end

end
