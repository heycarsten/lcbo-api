module Magiq
  class Param
    attr_reader :key, :type, :keys, :aliases

    OPTS = [
      TYPE  = :type,
      SOLO  = :solo,
      LIMIT = :limit,
      ALIAS = :alias,
      ARRAY = :array
    ]

    def initialize(key, opts = {})
      @key     = key.to_sym
      @type    = Types.lookup(opts[TYPE] || :string)
      @solo    = opts[SOLO]  ? true : false
      @limit   = opts[LIMIT] || Magiq[:array_param_limit]
      @aliases = opts[ALIAS] ? Array(opts[:alias]) : []
      @keys    = [@key].concat(@aliases).map(&:to_sym)

      @array = case opts[ARRAY]
      when :always
        :always
      when :allow
        :allow
      when nil, false
        false
      else
        raise ArgumentError, ":array option must be :always, :allow, or false, " \
        "not: #{opts[ARRAY].inspect}"
      end
    end

    def clean(raw_value)
      v = raw_value.to_s.strip
      v == '' ? nil : v
    end

    def accepts_array?
      @array ? true : false
    end

    def solo?
      @solo
    end

    def extract(raw_value)
      return unless raw_value

      if raw_value.is_a?(Array) && !accepts_array?
        raise BadParamError, "An array of values was passed to the `#{key}` " \
        "parameter but it is not permitted to accept more than one value."
      end

      value = case @array
      when :always
        raw_value.is_a?(Array) ? raw_value : raw_value.split(',')
      when :allow
        if raw_value.is_a?(Array)
          raw_value
        elsif raw_value.include?(',')
          raw_value.split(',')
        else
          raw_value
        end
      else
        raw_value
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
