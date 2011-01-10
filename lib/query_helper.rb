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
    case type
    when :stores
      StoresQuery.new(request, params).result
    when :products
      ProductsQuery.new(request, params).result
    when :inventories
      InventoriesQuery.new(request, params).result
    when :revisions
      RevisionsQuery.new(request, params).result
    when :datasets
      DatasetsQuery.new(request, params).result
    when :store
      { :result => find(:store, params[:id]) }
    when :product
      { :result => find(:product, params[:id]) }
    when :inventory
      { :store   => find(:store, params[:store_id]),
        :product => find(:product, params[:product_id]),
        :result  => find(:inventory, params[:product_id], params[:store_id]) }
    when :dataset
      { :result => find(:dataset, params[:id]) }
    else
      raise ArgumentError, "unrecognized type: #{type.inspect}"
    end
  end

end
