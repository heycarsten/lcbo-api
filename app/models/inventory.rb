class Inventory < Sequel::Model

  include Sequel::Archive

  set_primary_keys :product_id, :store_id

  belongs_to :crawl
  belongs_to :product
  belongs_to :store

  alias_attribute :product_no, :product_id
  alias_attribute :store_no, :store_id

  archive :updated_on, [:quantity]

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

