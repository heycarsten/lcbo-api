class Inventory < Sequel::Model

  plugin :timestamps, :update_on_create => true

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

  def revisions
    DB[:inventory_revisions].
      filter(:product_id => product_id, :store_id => store_id).
      order(:updated_on.desc)
  end

  def commit
    DB[:inventory_revisions].insert(
      :store_id => store_id,
      :product_id => product_id,
      :updated_on => updated_on,
      :quantity => quantity)
  end

  def as_json
    { :product_no => product_id,
      :store_no => store_id }.
    merge(super['values']).
    except(
      :is_dead,
      :product_id,
      :store_id,
      :crawl_id,
      :created_at,
      :updated_at)
  end

end
