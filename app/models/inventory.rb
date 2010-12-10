class Inventory < Sequel::Model

  plugin :timestamps, :update_on_create => true
  plugin :archive, :updated_on => [:quantity, :is_hidden]

  many_to_one :crawl
  many_to_one :product
  many_to_one :store

  def self.place(attrs)
    pid, sid = attrs.delete(:product_no), attrs.delete(:store_no)
    raise ArgumentError, 'attrs must include :product_no' unless pid
    raise ArgumentError, 'attrs must include :store_no'   unless sid
    attrs[:updated_at] = Time.now.utc
    if 0 == dataset.filter(:product_id => pid, :store_id => sid).update(attrs)
      attrs[:created_at] = attrs[:updated_at]
      attrs[:product_id] = pid
      attrs[:store_id] = sid
      dataset.insert(attrs)
    end
  end

  def as_json
    { :product_no => product_id,
      :store_no => store_id }.
      merge(super['values']).
      except(:is_hidden, :product_id, :store_id, :crawl_id, :created_at, :updated_at)
  end

end
