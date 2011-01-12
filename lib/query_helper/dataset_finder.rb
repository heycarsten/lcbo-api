module QueryHelper
  class DatasetFinder < Finder

    attr_accessor :crawl_id

    def initialize(request, params)
      super
      self.crawl_id = (params[:id] || params[:dataset_id])
    end

    def self.get(id)
      Crawl[id]
    end

    def as_args
      [crawl_id]
    end

  end
end
