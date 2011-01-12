module QueryHelper
  class StoreRevisionsQuery < Query

    attr_reader :store_id

    def initialize(request, params)
      super
      self.store_id = params[:store_id]
      validate
    end

    def self.table
      :store_revisions
    end

    def self.per_page
      50
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

    def dataset
      db.filter(:store_id => store_id).order(:updated_at.desc)
    end

    def as_csv(delimiter = ',')
      CSV.generate(:col_sep => delimiter) do |csv|
        cols = (db.columns - [:crawl_id])
        csv << cols
        csv_dataset.all do |row|
          csv << cols.map { |c| row[c] }
        end
      end
    end

    def as_json
      h = super
      h[:store]  = store.as_json
      h[:result] = page_dataset.all.map { |row| row.except(:crawl_id) }
      h
    end

  end
end
