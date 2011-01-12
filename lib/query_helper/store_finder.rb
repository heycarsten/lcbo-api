module QueryHelper
  class StoreFinder < Finder

    attr_accessor :store_id

    def initialize(request, params)
      super
      self.store_id = (params[:id] || params[:store_id])
    end

    def self.get(id)
      Store[id]
    end

    def as_args
      [store_id]
    end

  end
end
