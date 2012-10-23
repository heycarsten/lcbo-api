module QueryHelper
  class InventoriesQuery < Query

    attr_reader :product_id, :store_id

    def initialize(request, params)
      super
      self.product_id = params[:product_id] if params[:product_id].present?
      self.store_id   = params[:store_id]   if params[:store_id].present?
      validate
    end

    def self.table
      :inventories
    end

    def self.csv_columns
      Inventory.csv_columns
    end

    def self.as_csv_row(row)
      Inventory.as_csv_row(row)
    end

    def self.per_page
      50
    end

    def self.filterable_fields
      %w[ is_dead ]
    end

    def self.sortable_fields
      %w[ quantity updated_on ]
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
      @store ||= QueryHelper.find(:store, store_id)
    end

    def product
      @product ||= QueryHelper.find(:product, product_id)
    end

    def dataset
      case
      when product_id && store_id
        db.filter(
          product_id: product_id,
          store_id:   store_id)
      when product_id
        db.filter(product_id: product_id)
      when store_id
        db.filter(store_id: store_id)
      else
        db
      end.
      filter(filter_hash).
      order(*order)
    end

    def as_json
      h = super
      h[:store]   = store.as_json   if store_id
      h[:product] = product.as_json if product_id
      h[:result]  = page_dataset.all.map { |row| Inventory.as_json(row) }
      h
    end

  end
end
