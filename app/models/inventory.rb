class Inventory < ActiveRecord::Model

  set_primary_keys :product_id, :store_id

  include ActiveRecord::Archive

  archive :updated_on, [:quantity]

  def self.place(attrs)
    if (inventory = self[attrs[:product_no], attrs[:store_no]])
      inventory.update(attrs)
    else
      create(attrs)
    end
  end

  def self.slug(product_no, store_no)
    "product.#{product_no}:store.#{store_no}"
  end

  def self.keys(store_no, product_no)
    db.keys(key[slug(store_no, product_no)])
  end

  def self.keys_for_store(store_no)
    keys('*', store_no)
  end

  def self.keys_for_product(product_no)
    keys(product_no, '*')
  end

  def self.create(attrs)
    super attrs.merge(:id => slug(attrs[:product_no], attrs[:store_no]))
  end

  def self.[](*args)
    if args.size == 1
      super args[0]
    else
      super slug(args[0], args[1])
    end
  end

  def geo
    store.geo
  end

  def store
    if (obj = Store[store_no])
      obj
    else
      raise MissingID, "No store found with id: #{store_no.inspect}"
    end
  end

  def product
    if (obj = Product[product_no])
      obj
    else
      raise MissingID, "No product found with id: #{product_no.inspect}"
    end
  end

  def as_json
    to_hash :id, :is_hidden
  end

end
