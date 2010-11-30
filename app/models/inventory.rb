class Inventory < Ohm::Model

  include Ohm::Typecast
  include Ohm::Archive
  include Ohm::ToHash
  include Ohm::CountAll
  include Ohm::Sunspot
  include Ohm::Rails

  attribute :is_hidden,   Boolean
  attribute :crawled_at,  Time
  attribute :product_no,  Integer
  attribute :store_no,    Integer
  attribute :quantity,    Integer
  attribute :updated_on,  String

  archive :updated_on, [:quantity]

  sunspot do
    boolean :is_hidden
    integer :product_no
    integer :store_no
    integer :quantity
    location :geo
  end

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
