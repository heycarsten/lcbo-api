module QueryHelper

  PER_PAGE = 20
  MIN_PER_PAGE = 5
  MAX_PER_PAGE = 200
  MAX_PRODUCT_ID = 999_999_999

  class BadParamError < StandardError; end
  class NotImplementedError < StandardError; end

  def self.query(type, request, params)
    case type
    when :stores
      StoresQuery.new(request, params).result
    when :products
      ProductsQuery.new(request, params).result
    end
  end

  class Query
    attr_accessor :request, :params, :page, :per_page, :q

    def initialize(params, request)
      @request = request
      self.page      = params[:page]      if params[:page].present?
      self.per_page  = params[:per_page]  if params[:per_page].present?
      self.q         = params[:q]         if params[:q].present?
      self.sort_by   = params[:sort_by]   if params[:stort_by].present?
      self.order     = params[:order]     if params[:order].present?
      self.where     = params[:where]     if params[:where].present?
      self.where_not = params[:where_not] if params[:where_not].present?
    end

    def where=(value)
      @where = split_filter_list(:where, value)
    end

    def where
      @where || WHERE.reject { |w| where_not.include?(w) }
    end

    def where_not=(value)
      @where_not = split_filter_list(:where_not, value)
    end

    def where_not
      @where_not || WHERE_NOT.reject { |w| where.include?(w) }
    end

    def filter_hash
      Hash[where.map { |w| [w.to_sym, true ] }].
        merge(Hash[where_not.map { |w| [w.to_sym, false] }])
    end

    def sort_by=(value)
      field = value.to_s.downcase
      unless SORTABLE_FIELDS.include?(field)
        raise BadParamError, "The value supplied for :sort_by " \
        "(#{value.inspect}) is not a sortable field. Try one of: " \
        "#{SORTABLE_FIELDS.inspect}"
      end
      @sort_by = field
    end

    def sort_by
      @sort_by || SORT_BY
    end

    def order=(value)
      case value.to_s.downcase
      when 'asc', 'desc'
        @order = value.to_s.downcase
      else
        raise BadParamError, "The value supplied for :order " \
        "(#{value.inspect}) is not a valid order. It must be 'asc' ascending " \
        "or 'desc' descending."
      end
    end

    def order
      @order || ORDER
    end

    def page=(value)
      unless value.to_i > 0
        raise BadParamError, "The value suppled for :page " \
        "(#{value.inspect}) is not a valid page number. It must be a number " \
        "greater than zero."
      end
      @page = value.to_i
    end

    def page
      @page || 1
    end

    def per_page=(value)
      unless (MIN_PER_PAGE..MAX_PER_PAGE).include?(value.to_i)
        raise BadParamError, "The value supplied for :per_page " \
        "(#{value.inspect}) is not a valid number of items per page. It must " \
        "be a number between #{MIN_PER_PAGE} and #{MAX_PER_PAGE}."
      end
      @per_page = value.to_i
    end

    def per_page
      @per_page || PER_PAGE
    end

    def has_fulltext?
      q.present?
    end

    def page
      @page ||= dataset.paginate(page, per_page)
    end

    def path_for_page(page_num)
      path = request.fullpath.dup
      case
      when path.include?('page=')
        path.gsub(/page=[0-9]+/, "page=#{page_num}")
      when path.include?('?')
        path + "&page=#{page_num}"
      else
        path + "?page=#{page_num}"
      end
    end

    def pager
      [:current, :next, :previous, :first, :final].reduce(
        :total_record_count => page.pagination_record_count,
        :current_page_record_count => page.current_page_record_count,
        :is_first_page => page.first_page?,
        :is_final_page => page.last_page?
      ) do |hsh, key|
        num = page.send(key)
        hsh.merge(
          :"#{key}_page" => num,
          :"#{k}_page_path" => path_for_page(num)
        )
      end
    end

    def result
      h = {}
      h[:pager] = pager
      h
    end

    protected

    def validate
      if (where && where_not) && where.any? { |w| where_not.include?(w) }
        raise BadParamError, "One or more of the fields supplied for :where " \
        "(#{where.inspect}) matches one or more of the fields supplied for " \
        ":where_not (#{where_not.inspect}). These parameters must contain " \
        "indifferent values."
      end
    end

    def split_filter_list(name, value)
      vals = value.to_s.split(',').map { |v| v.strip.downcase }
      unless vals.all? { |v| FILTERABLE_FIELDS.include?(v) }
        raise BadParamError, "The value supplied for :#{name} " \
        "(#{value.inspect}) must contain only filterable fields separated " \
        "by commas: #{name}=#{FILTERABLE_FIELDS.join(',')}"
      end
      vals
    end
  end

  class StoresQuery < Query
    FILTERABLE_FIELDS = %w[
      is_dead
      has_wheelchair_accessability
      has_bilingual_services
      has_product_consultant
      has_tasting_bar
      has_beer_cold_room
      has_special_occasion_permits
      has_vintages_corner
      has_parking
      has_transit_access ]

    SORTABLE_FIELDS = %w[
      distance_in_meters
      inventory_volume_in_milliliters
      id
      products_count
      inventory_count
      inventory_price_in_cents ]

    SORT_BY   = 'inventory_volume_in_milliliters'
    ORDER     = 'desc'
    WHERE     = []
    WHERE_NOT = %w[ is_dead ]

    attr_accessor :product_id, :lat, :lon, :geo

    def initialize(params, request)
      super
      if params[:is_geo_q]
        self.geo = params[:q] if params[:q].present?
      else
        self.geo = params[:geo] if params[:geo].present?
        self.q   = params[:q] if params[:q].present?
      end
      self.lat = params[:lat] if params[:lat].present?
      self.lon = params[:lon] if params[:lon].present?
      validate
    end

    def product_id=(value)
      unless (1..MAX_PRODUCT_ID).include?(value.to_i)
        raise BadParamError, "The value supplied for :product_id " \
        "(#{value.inspect}) is not a valid product ID. It must be a number " \
        "between 1 and #{MAX_PRODUCT_ID}."
      end
      @product_id = value.to_i
    end

    def lat=(value)
      unless (-90.0..90.0).include?(value.to_f)
        raise BadParamError, "The value supplied for :lat " \
        "(#{value.inspect}) is not a valid latitude. It must be a number " \
        "between -90.0 and 90.0."
      end
      @lat = value.to_f
    end

    def lon=(value)
      unless (-180.0..180.0).include?(value.to_f)
        raise BadParamError, "The value supplied for :lon " \
        "(#{value.inspect}) is not a valid longitude. It must be a number " \
        "between -180.0 and 180.0."
      end
      @lon = value.to_f
    end

    def has_geo?
      case
      when geo.present? && (lat.present? || lon.present?)
        raise BadParamError, "Provided with both geocodeable query (:geo) " \
        "and latitude (:lat) / longitude (:lon). Please provide either a " \
        "geocodable query (:geo) or a latitude and longitude."
      when lat.present? && lon.blank?
        raise BadParamError, "Supply a longitude (:lon) " \
        "parameter in addition to latitude (:lat) to perform a spatial search."
      when lon.present? && lat.blank?
        raise BadParamError, "Supply a latitude (:lat) " \
        "parameter in addition to longitude (:lon) to perform spatial search."
      else
        lat.present? && lon.present?
      end
    end

    def dataset
      case
      when has_fulltext?
        db[:stores].search(q)
      when has_geo?
        Store.distance_from(lat, lon)
      when has_geo? && product_id
        Store.distance_from_with_product(lat, lon, product_id)
      else
        db[:stores]
      end.
      filter(filter_hash).
      order(sort_by.to_sym => order)
    end

    def result
      h = super
      h[:product] = Product[product_id].as_json if product_id
      h[:result]  = page.map { |row| Store.as_json(row) }
      h
    end
  end

  class ProductsQuery < Query
    FILTERABLE_FIELDS = %w[
      is_dead
      is_discontinued
      has_value_added_promotion
      has_limited_time_offer
      has_bonus_reward_miles
      is_seasonal
      is_vqa
      is_kosher ]

    SORTABLE_FIELDS = %w[
      id
      price_in_cents
      regular_price_in_cents
      limited_time_offer_savings_in_cents
      limited_time_offer_ends_on
      bonus_reward_miles
      bonus_reward_miles_ends_on
      package_unit_volume_in_milliliters
      total_package_units
      total_package_volume_in_milliliters
      volume_in_milliliters
      alcohol_content
      price_per_liter_of_alcohol_in_cents
      price_per_liter_in_cents
      inventory_count
      inventory_volume_in_milliliters
      inventory_price_in_cents
      released_on ]

    SORT_BY   = 'inventory_volume_in_milliliters'
    ORDER     = 'desc'
    WHERE     = []
    WHERE_NOT = %w[ is_dead ]

    def initialize(params)
      super
      validate
    end

    def dataset
      case
      when has_fulltext?
        db[:products].search(q)
      else
        db[:products]
      end.
      filter(filter_hash).
      order(sort_by.to_sym => order)
    end

    def result
      h = {}
      h[:pager] = pager
      h[:result] = page.map { |row| Product.as_json(row) }
      h
    end
  end

end
