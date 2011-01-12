module QueryHelper
  class StoresQuery < Query

    attr_accessor :product_id, :lat, :lon, :geo

    def initialize(request, params)
      super
      if params[:is_geo_q]
        self.geo = params[:q] if params[:q].present?
      else
        self.geo = params[:geo] if params[:geo].present?
        self.q = params[:q] if params[:q].present?
      end
      self.product_id = params[:product_id] if params[:product_id].present?
      self.lat = params[:lat] if params[:lat].present?
      self.lon = params[:lon] if params[:lon].present?
      validate
    end

    def self.table
      :stores
    end

    def self.filterable_fields
      %w[
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
    end

    def self.sortable_fields
      %w[
      distance_in_meters
      inventory_volume_in_milliliters
      id
      products_count
      inventory_count
      inventory_price_in_cents ]
    end

    def self.order
      'inventory_volume_in_milliliters.desc'
    end

    def self.where_not
      %w[ is_dead ]
    end

    def product_id=(value)
      unless value.to_i > 0
        raise BadQueryError, "The value supplied for the product_id " \
        "parameter (#{value}) is not valid. It must be a number greater than " \
        "zero."
      end
      @product_id = value.to_i
    end

    def lat=(value)
      unless QueryHelper.is_float?(value) && (-90.0..90.0).include?(value.to_f)
        raise BadQueryError, "The value supplied for the lat parameter " \
        "(#{value}) is not valid. It must be a valid latitude; a number " \
        "between -90.0 and 90.0."
      end
      @lat = value.to_f
    end

    def lon=(value)
      unless QueryHelper.is_float?(value) && (-180.0..180.0).include?(value.to_f)
        raise BadQueryError, "The value supplied for the lon parameter " \
        "(#{value}) is not valid. It must be a valid longitude; a number " \
        "between -180.0 and 180.0."
      end
      @lon = value.to_f
    end

    def latitude
      has_geo? ? geocode.lat : lat
    end

    def longitude
      has_geo? ? geocode.lng : lon
    end

    def is_spatial?
      has_latlon? || has_geo?
    end

    def has_geo?
      geo.present?
    end

    def has_lat?
      params[:lat].present?
    end

    def has_lon?
      params[:lon].present?
    end

    def has_latlon?
      has_lat? && has_lon?
    end

    def _filtered_dataset
      case
      when is_spatial? && product_id
        Store.distance_from_with_product(latitude, longitude, product_id)
      when is_spatial?
        Store.distance_from(latitude, longitude)
      when product_id
        DB[:stores].join(:inventories,
          :store_id   => :id,
          :product_id => product_id)
      else
        DB[:stores]
      end.
      filter(filter_hash)
    end

    def _ordered_dataset
      if is_spatial?
        _filtered_dataset.order(:distance_in_meters.asc)
      else
        _filtered_dataset.order(*order)
      end
    end

    def dataset
      if has_fulltext?
        _ordered_dataset.full_text_search([:tags], q)
      else
        _ordered_dataset
      end
    end

    def product
      QueryHelper.find(:product, product_id)
    end

    def as_json
      h = super
      h[:product] = product if product_id
      h[:result]  = page_dataset.all.map { |row| Store.as_json(row) }
      h
    end

    def as_csv
      FasterCSV.generate(:encoding => 'UTF-8') do |csv|
        csv << Store.public_fields
        csv_dataset.all do |row|
          csv << Store.as_csv(row)
        end
      end
    end

    private

    def geocode
      @geocode ||= GEO[geo].first.geometry.location
    end

    def validate
      super
      case
      when has_geo? && (has_lat? || has_lon?)
        raise BadQueryError, "Provided with both geocodeable query (:geo) " \
        "and latitude (:lat) / longitude (:lon). Please provide either a " \
        "geocodable query (:geo) or a latitude and longitude."
      when has_lat? && !has_lon?
        raise BadQueryError, "The lon parameter must be supplied in addition " \
        "to the lat parameter to perform a spatial search."
      when has_lon? && !has_lat?
        raise BadQueryError, "The lat parameter must be supplied in addition " \
        "to the lon parameter to perform a spatial search."
      end
    end

  end
end