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

    def self.csv_columns
      @csv_columns ||= (DB[table].columns - [:crawl_id])
    end

    def self.as_csv_row(row)
      csv_columns.map { |c| row[c] }
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
      db.filter(store_id: store_id).order(:updated_at.desc)
    end

    def as_json
      h = super
      h[:store]  = store.as_json
      h[:result] = page_dataset.all.map { |row| row.except(:crawl_id) }
      h
    end

  end
end
