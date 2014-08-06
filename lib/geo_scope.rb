module GeoScope
  extend ActiveSupport::Concern

  EARTH_RADIUS_M = 6371000
  LATLON_RE = /\-{0,1}[0-9]+\.[0-9]+/

  module_function def deg2rad(deg)
    deg.to_f * (Math::PI / 180.0)
  end

  module_function def distance_sql(latdeg, lngdeg)
    lat, lng = deg2rad(latdeg), deg2rad(lngdeg)
    %{
      CAST(
        ROUND(
          ACOS(
            least(1,
              COS(#{lat}) * COS(#{lng}) * COS(latrad) * COS(lngrad) +
              COS(#{lat}) * SIN(#{lng}) * COS(latrad) * SIN(lngrad) +
              SIN(#{lat}) * SIN(latrad)
            )
          ) * #{EARTH_RADIUS_M}
        )
      AS bigint)
    }
  end

  included do
    scope :distance_from, ->(lat, lon) {
      sql = GeoScope.distance_sql(lat, lon)
      select("#{table_name}.*, #{sql} AS distance_in_meters").order('distance_in_meters ASC')
    }
  end
end
