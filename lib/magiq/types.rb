module Magiq
  module Types
    module_function

    def registry
      @registry ||= {}
    end

    def register(ident, adapter)
      registry[ident.to_sym] = adapter
    end

    def lookup(name)
      if (found = registry[name.to_sym])
        found
      else
        raise ArgumentError, "no type is registered under: #{name.inspect}"
      end
    end

    class Type
      attr_reader :raw

      def self.cast(raw)
        new(raw).cast!
      end

      def initialize(raw)
        @raw = raw.to_s.strip
      end

      def cast!
        raw
      end

      protected

      def bad!(message)
        raise BadParamError, message
      end
    end

    class String < Type
      def cast!
        raw
      end
    end
    register :string, String

    class Bool < Type
      def cast!
        case v = raw.downcase
        when 't', 'true', '1', 'yes', 'y'
          true
        when 'f', 'false', '0', 'no', 'n'
          false
        else
          bad! "provided value of #{raw.inspect} is not permitted, the " \
          "permitted values are: \"true\", or \"false\""
        end
      end
    end
    register :bool, Bool

    class Float < Type
      def cast!
        raw.to_f
      end
    end
    register :float, Float

    class Int < Type
      def cast!
        raw.to_i
      end
    end
    register :int, Int

    class Latitude < Type
      def cast!
        case v = raw.to_f
        when 0.0
          bad! "provided value of #{raw.inspect} is not permitted, it must " \
          "be a valid latitude in the range of -90.0 to 90.0"
        when -90..90
          v
        else
          bad! "provided value of #{raw.inspect} is not permitted, it must " \
          "be a valid latitude in the range of -90.0 to 90.0"
        end
      end
    end
    register :latitude, Latitude

    class Longitude < Type
      def cast!
        case v = raw.to_f
        when 0.0
          bad! "provided value of #{raw.inspect} is not permitted, it must " \
          "be a valid longitude within -180.0 to 180.0"
        when -180..180
          v
        else
          bad! "provided value of #{raw.inspect} is not permitted, it must " \
          "be a valid longitude within -180.0 to 180.0"
        end
      end
    end
    register :longitude, Longitude

    class Whole < Type
      def cast!
        if (v = raw.to_i) >= 0
          v
        else
          bad! "provided value of #{raw.inspect} is not permitted, it must " \
          "be a non-negative number"
        end
      end
    end
    register :whole, Whole

    class EnumSort < Type
      def cast!
        case raw.downcase
        when 'asc'
          :asc
        when 'desc'
          :desc
        else
          bad! "provided value of #{raw.inspect} is not permitted, permitted " \
          "values are: \"asc\", or \"desc\""
        end
      end
    end
    register :enum_sort, EnumSort
  end
end
