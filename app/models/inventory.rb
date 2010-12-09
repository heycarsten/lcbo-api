class Inventory < Sequel::Model

  plugin :timestamps, :update_on_create => true
  plugin :archive, :updated_on => [:quantity]

  many_to_one :crawl
  many_to_one :product
  many_to_one :store

  alias_method :product_no, :product_id
  alias_method :store_no, :store_id

  def self.place(attrs)
    pid = attrs[:product_id] || attrs[:product_no]
    sid = attrs[:store_id] || attrs[:store_no]
    if (inventory = where(:product_id => pid, :store_id => sid).first)
      inventory.update_attributes(attrs)
    else
      create(attrs)
    end
  end

  def as_json
    { :product_no => product_id,
      :store_no   => store_id }.
      merge(super).
      exclude(:is_hidden, :product_id, :store_id)
  end

end

