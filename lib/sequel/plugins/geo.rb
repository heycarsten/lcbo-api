module Sequel
  module Plugins
    module Geo

      module ClassMethods
        EARTH_RADIUS_M = 6371000

        def deg2rad(deg)
          deg.to_f * (Math::PI / 180.0)
        end

        def distance_sql(latdeg, lngdeg)
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
      end

      module DatasetMethods
        def distance_from(latdeg, lngdeg)
          sql = model.distance_sql(latdeg, lngdeg)
          select_append(sql.lit => :distance_in_meters).
            order(:distance_in_meters.asc)
        end
      end

    end
  end
end
