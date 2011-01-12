module QueryHelper
  class DatasetsQuery < Query

    attr_reader :dataset_id

    def initialize(request, params)
      super
      self.dataset_id = params[:dataset_id] if params[:dataset_id].present?
      validate
    end

    def self.table
      :crawls
    end

    def self.sortable_fields
      %w[
        id
        created_at
        total_products
        total_stores
        total_inventories
        total_product_inventory_count
        total_product_inventory_volume_in_milliliters
        total_product_inventory_price_in_cents
      ]
    end

    def self.order
      'id.desc'
    end

    def dataset_id=(value)
      unless value.to_i > 0
        raise BadQueryError, "The value supplied for the dataset_id " \
        "parameter (#{value}) is not valid. It must be a number greater than " \
        "zero."
      end
      @dataset_id = value.to_i
    end

    def dataset
      db.filter(:state => 'finished').order(*order)
    end

    def as_json
      h = super
      h[:result] = page_dataset.all.map { |row| Crawl.as_json(row) }
      h
    end

  end
end
