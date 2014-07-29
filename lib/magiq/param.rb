module Magiq
  class Param
    attr_reader :name, :type

    def initialize(name, opts = {})
      @name  = name.to_sym
      @type  = Types.lookup(opts[:type] || :string)
      @array = opts[:array] ? true : false
    end

    def clean(raw_value)
      if (v = raw_value.to_s.strip) != ''
        v
      else
        nil
      end
    end

    def extract(value)
      return unless value

      if value.is_a?(Array) && !@array
        raise BadParamError, "An array of values was passed to the `#{name}` " \
        "parameter but it is not permitted to accept more than one value."
      end

      if value.is_a?(Array)
        value.map { |v| @type.cast(clean(v)) }
      else
        if (v = clean(value))
          @type.cast(v)
        else
          nil
        end
      end
    end
  end
end
