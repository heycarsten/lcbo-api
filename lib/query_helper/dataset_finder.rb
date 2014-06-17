module QueryHelper
  class DatasetFinder < Finder
    attr_accessor :crawl_id

    def initialize(request, params)
      super
      self.crawl_id = (params[:id] || params[:dataset_id])
    end

    def self.find(*args)
      if args.length == 1 && args.first == 'latest'
        get(args.first)
      else
        super
      end
    end

    def self.get(id)
      if id.to_s == 'latest'
        Crawl.is(:finished).order(id: :desc).first
      else
        Crawl.is(:finished).where(id: id).first
      end
    end

    def as_args
      [crawl_id]
    end
  end
end
