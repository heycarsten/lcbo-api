module QueryHelper
  class ProductsResult
  end

  class StoresResult
  end

  class Query
    attr_reader :kind, :params

    def initialize(kind, params)
      @kind   = kind
      @params = params
    end

    def self.products(params)
      new(:products, params).query
    end

    def self.stores(params)
      new(:stores, params).query
    end

    def validate!
      [:lat, :lon]
      [:q]
      [:geo]
    end

    def is_geo_q?
      params[:is_geo_q] ? true : false
    end

    def lat
      params[:lat].to_f
    end

    def lon
      params[:lon].to_f
    end

    def q
      params[:q] unless is_geo_q?
    end

    def geo
      if is_geo_q?
        params[:q]
      else
        params[:geo]
      end
    end

    def query
      case kind
      when :products
        Store.distance_from_point(params[:lat], params[:lon])
      when :stores
      end
    end

    # Full-text search on stores that have product 18
    # /product/18/stores?q=queen+and+brock

    # Spatial search on stores that have product 18
    # /product/18/stores?lat=48.7734&lon=-78.3345

    # Geospatial search on stores that have product 18
    # /product/18/stores?geo=m6r2g5

    # 
  end
end
