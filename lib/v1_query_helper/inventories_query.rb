module V1QueryHelper
  class InventoriesQuery < Query
    attr_reader :product_id, :store_id

    def initialize(request, params)
      super
      self.product_id = params[:product_id] if params[:product_id].present?
      self.store_id   = params[:store_id]   if params[:store_id].present?
      validate
    end

    def self.per_page
      50
    end

    def self.filterable_fields
      %w[ is_dead ]
    end

    def self.sortable_fields
      { quantity: :quantity,
        updated_on: :reported_on }
    end

    def self.order
      'quantity.desc'
    end

    def self.where
      []
    end

    def self.where_not
      %w[ is_dead ]
    end

    def product_id=(value)
      unless value.to_i > 0
        raise BadQueryError, "The value supplied for the product_id " \
        "parameter (#{value}) is not valid. It must be a number greater than " \
        "zero."
      end

      @product_id = value.to_i
    end

    def store_id=(value)
      unless value.to_i > 0
        raise BadQueryError, "The value supplied for the store_id " \
        "parameter (#{value}) is not valid. It must be a number greater than " \
        "zero."
      end

      @store_id = value.to_i
    end

    def store
      @store ||= V1QueryHelper.find(:store, store_id)
    end

    def product
      @product ||= V1QueryHelper.find(:product, product_id)
    end

    def scope
      case
      when product_id && store_id
        model.where(
          product_id: product_id,
          store_id:   store_id)
      when product_id
        model.where(product_id: product_id)
      when store_id
        model.where(store_id: store_id)
      else
        model
      end.
      where(filter_hash).
      order(*order)
    end

    def as_json
      h = super
      h[:store]   = StoresQuery.serialize(store)     if store_id
      h[:product] = ProductsQuery.serialize(product) if product_id
      h[:result]  = page_scope.all.map { |inventory| serialize(inventory) }
      h
    end
  end
end
