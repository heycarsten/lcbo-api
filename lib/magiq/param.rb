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

    def extract_from(params)
      return unless params.key?(name)
      return unless v = params[name]

      if v.is_a?(Array) && !@array
        raise BadParamError, "An array of values was passed to the `#{name}` " \
        "parameter but it is not permitted to accept more than one value."
      end

      if v.is_a?(Array)
        v.map { |val| @type.cast(clean(val)) }
      else
        clean(v) ? @type.cast(v) : nil
      end
    end
  end
end
