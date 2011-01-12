module QueryHelper
  class ProductRevisionsQuery < Query

    attr_reader :product_id

    def initialize(request, params)
      super
      self.product_id = params[:product_id]
      validate
    end

    def self.table
      :product_revisions
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

    def product
      @product ||= QueryHelper.find(:product, product_id)
    end

    def dataset
      db.filter(:product_id => product_id).order(:updated_at.desc)
    end

    def as_csv
      CSV.generate do |csv|
        cols = (db.columns - [:crawl_id])
        csv << cols
        csv_dataset.all do |row|
          csv << cols.map { |c| row[c] }
        end
      end
    end

    def as_json
      h = super
      h[:product] = product
      h[:result] = page_dataset.all.map { |row| row.except(:crawl_id) }
      h
    end

  end
end
