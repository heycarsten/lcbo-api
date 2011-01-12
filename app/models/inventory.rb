class Inventory < Sequel::Model

  plugin :timestamps, :update_on_create => true
  plugin :archive, :updated_on
  plugin :csv

  many_to_one :crawl
  many_to_one :product
  many_to_one :store

  PRIVATE_FIELDS = [:crawl_id, :created_at]

  def self.public_fields
    @public_fields ||= (columns - PRIVATE_FIELDS)
  end

  def self.as_json(hsh)
    hsh.
      except(*PRIVATE_FIELDS).
      merge(:product_no => hsh[:product_id], :store_no => hsh[:store_id])
  end

  def self.place(attrs)
    pid, sid = attrs.delete(:product_id), attrs.delete(:store_id)
    raise ArgumentError, 'attrs must include :product_id' unless pid
    raise ArgumentError, 'attrs must include :store_id'   unless sid
    attrs[:updated_at] = Time.now.utc
    if 0 == dataset.filter(:product_id => pid, :store_id => sid).update(attrs)
      attrs[:created_at] = attrs[:updated_at]
      attrs[:product_id] = pid
      attrs[:store_id] = sid
      dataset.insert(attrs)
    end
  end

  def as_json
    self.class.as_json(super['values'])
  end

end
