class Inventory < ActiveRecord::Base
  belongs_to :crawl
  belongs_to :product
  belongs_to :store

  def compound_id
    "#{product_id}-#{store_id}"
  end

  def self.place(attrs)
    pid, sid = attrs.delete(:product_id), attrs.delete(:store_id)

    raise ArgumentError, 'attrs must include :product_id' unless pid
    raise ArgumentError, 'attrs must include :store_id'   unless sid

    attrs[:updated_at] = Time.now.utc
    attrs[:is_dead]    = false

    if 0 == where(product_id: pid, store_id: sid).update_all(attrs)
      attrs[:created_at] = attrs[:updated_at]
      attrs[:product_id] = pid
      attrs[:store_id]   = sid

      create!(attrs)
    end
  end
end
