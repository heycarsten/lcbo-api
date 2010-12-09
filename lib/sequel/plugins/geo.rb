module Sequel
  module Plugins
    module Geo
      def self.apply(model)
      end

      def self.configure(model, opts = {})
      end

      module ClassMethods
        EARTH_RADIUS_M = 6371000

        def deg2rad(deg)
          deg.to_f * (Math::PI / 180.0)
        end

        def distance_sql(latdeg, lngdeg)
          lat, lng = deg2rad(latdeg), deg2rad(lngdeg)
          %{
            (ACOS(
              least(1,
                COS(#{lat}) * COS(#{lng}) * COS(latrad) * COS(lngrad) +
                COS(#{lat}) * SIN(#{lng}) * COS(latrad) * SIN(lngrad) +
                SIN(#{lat}) * SIN(latrad)
              )
            ) * #{EARTH_RADIUS_M})
          }
        end
      end

      module InstanceMethods
      end

      module DatasetMethods
        def distance_from(latdeg, lngdeg)
          sql = model.distance_sql(latdeg, lngdeg)
        end

        end
        def f_origin_bbox(origin, within)
          bounds = Geokit::Bounds.from_point_and_radius(origin, within, :units => :kms)
          sw, ne = bounds.sw, bounds.ne
          filter = self
          if bounds.crosses_meridian?
            filter = filter.filter{(lng < ne.lng) | (lng > sw.lng)}
          else
            filter = filter.filter{(lng < ne.lng) & (lng > sw.lng)}
          end
          filter.filter{(lat < ne.lat) & (lat > sw.lat)}
        end

        def f_origin(origin, within)
          sql = model.distance_sql(origin)
          f_origin_bbox(origin, within).filter{sql.lit <= within}
        end
      end
    end
  end
end
