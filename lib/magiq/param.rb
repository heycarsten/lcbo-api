module Magiq
  class Param
    attr_reader :key, :type, :keys, :aliases

    def initialize(key, opts = {})
      @key     = key.to_sym
      @type    = Types.lookup(opts[:type] || :string)
      @array   = opts[:array] ? true : false
      @solo    = opts[:solo]  ? true : false
      @limit   = opts[:limit] || Magiq[:array_param_limit]
      @aliases = opts[:alias] ? Array(opts[:alias]) : []
      @keys    = [@key].concat(@aliases).map(&:to_sym)
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
        raise BadParamError, "An array of values was passed to the `#{key}` " \
        "parameter but it is not permitted to accept more than one value."
      end

      if value.is_a?(Array) && @limit && value.size > @limit
        raise BadParamError, "The number of items passed to the `#{key}` " \
        "parameter is #{value.size} which exceeds the permitted maxium of " \
        "#{@limit} items."
      end

      if value.is_a?(Array)
        return value.map { |v| @type.cast(clean(v)) }
      end

      return unless (v = clean(value))

      @type.cast(v)
    end
  end
end
