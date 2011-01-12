module QueryHelper

  MIN_PER_PAGE = 5
  MAX_PER_PAGE = 100

  class NotFoundError < StandardError; end
  class BadQueryError < StandardError; end
  class GeocoderError < StandardError; end
  class NotImplementedError < StandardError; end

  def self.is_float?(val)
    return false unless val
    return true if val.is_a?(Numeric)
    val =~ /\A\-{0,1}[0-9]+\.[0-9]+\Z/ ? true : false
  end

  def self.find(type, *args)
    instance = case type
    when :store
      Store[*args]
    when :product
      Product[*args]
    when :inventory
      Inventory[*args]
    when :dataset
      Dataset[*args]
    else
      raise ArgumentError, "unrecognized type: #{type.inspect}"
    end
    return instance.as_json if instance
    raise NotFoundError, "No #{type} exists with id: #{args.join(', ')}."
  end

  def self.query(type, request, params)
    { :stores      => StoresQuery,
      :store       => StoreQuery,
      :products    => ProductsQuery,
      :product     => ProductQuery,
      :inventories => InventoriesQuery,
      :inventory   => InventoryQuery,
      :revisions   => RevisionsQuery,
      :datasets    => DatasetsQuery,
      :dataset     => DatasetQuery
    }[type].new(request, params)
  end

end
