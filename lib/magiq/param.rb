module Magiq
  class Param
    attr_reader :name, :type

    def initialize(name, opts = {})
      @name  = name.to_sym
      @type  = Types.lookup(opts[:type] || :string)
      @array = opts[:array] ? true : false
      @solo  = opts[:solo]  ? true : false
    end

    def clean(raw_value)
      v = raw_value.to_s.strip
      v == '' ? nil : v
    end

    def accepts_array?
      @array
    end

    def solo?
      @solo
    end

    def extract(value)
      return unless value

      if value.is_a?(Array) && !accepts_array?
        raise BadParamError, "An array of values was passed to the `#{name}` " \
        "parameter but it is not permitted to accept more than one value."
      end

      if value.is_a?(Array)
        return value.map { |v| @type.cast(clean(v)) }
      end

      return unless (v = clean(value))

      @type.cast(v)
    end
  end
end
