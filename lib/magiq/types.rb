require 'date'

module Magiq
  module Types
    module_function

    def registry
      @registry ||= {}
    end

    def register(id, adapter)
      registry[id.to_sym] = adapter
    end

    def lookup(id)
      if (found = registry[id.to_sym])
        found
      else
        raise ArgumentError, "no type is registered under: #{id.inspect}"
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
        raw == nil ? nil : raw.to_s
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

    class ID < Type
      def cast!
        v = raw.to_i

        if v > 0
          v
        else
          bad! "provided value of #{raw.inspect} is not permitted, it must " \
          "be a numerical ID greater than zero."
        end
      end
    end
    register :id, ID

    class UPC < Type
      UPC_RNG = /[^0-9]/
      UPC_MAX = 9999999999999

      def cast!
        v = raw.to_s.gsub(UPC_RNG, '').to_i

        if v > 0 && v <= UPC_MAX
          v
        else
          bad! "provided value of #{raw.inspect} is not permitted, it must " \
          "be a valid UPC with a numerical value between zero and #{UPC_MAX}."
        end
      end
    end
    register :upc, UPC

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

    class Date < Type
      DATE_RNG = /[12]{1}[0-9]{3}\-[10]{1}[0-9]{1}\-[0123]{1}[0-9]{1}/

      def cast!
        if raw =~ DATE_RNG
          Date.parse($1)
        else
          bad! "provided value of #{raw.inspect} is not permitted, it must " \
          "be an ISO 8601 formatted date: YYYY-MM-DD"
        end
      end
    end
    register :date, Date
  end
end
