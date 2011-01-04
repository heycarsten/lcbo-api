module QueryHelper
  class RevisionsQuery < Query

    attr_reader :product_id, :store_id

    def initialize(request, params)
      super
      self.product_id = params[:product_id] if params[:product_id].present?
      self.store_id   = params[:store_id]   if params[:store_id].present?
      validate
    end

    def self.table
      lambda { |query|
        case
        when query.product_id && query.store_id
          :inventory_revisions
        when query.product_id
          :product_revisions
        when query.store_id
          :store_revisions
        end
      }
    end

    def self.per_page
      50
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
        DB[:inventory_revisions].
          filter(:product_id => product_id, :store_id => store_id).
          order(:updated_on.desc)
      when product_id
        DB[:product_revisions].
          filter(:product_id => product_id).
          order(:updated_at.desc)
      when store_id
        DB[:store_revisions].
          filter(:store_id => store_id).
          order(:updated_at.desc)
      end
    end

    def result
      h = {}
      h[:pager]   = pager
      h[:store]   = store   if store_id
      h[:product] = product if product_id
      h[:result]  = page_dataset.all.map { |row| row.except(:crawl_id) }
      h
    end

  end
end
