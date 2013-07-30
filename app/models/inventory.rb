class Inventory < Sequel::Model

  plugin :timestamps, update_on_create: true
  plugin :api,
    private: [:crawl_id, :created_at],
    aliases: { product_id: :product_no, store_id: :store_no }

  many_to_one :crawl
  many_to_one :product
  many_to_one :store

  def self.place(attrs)
    pid, sid = attrs.delete(:product_id), attrs.delete(:store_id)
    raise ArgumentError, 'attrs must include :product_id' unless pid
    raise ArgumentError, 'attrs must include :store_id'   unless sid
    attrs[:updated_at] = Time.now.utc
    attrs[:is_dead] = false
    if 0 == dataset.where(product_id: pid, store_id: sid).update(attrs)
      attrs[:created_at] = attrs[:updated_at]
      attrs[:product_id] = pid
      attrs[:store_id]   = sid
      dataset.insert(attrs)
    end
  end

end
