module Magiq
  class Query
    attr_reader :params

    def self.model_name=(val)
      @model_name = val
    end

    def self.model
      @model ||= Object.const_get(@model_name.to_s.classify)
    end

    def self.model=(model)
      @model = model
    end

    def self.builder
      @builder ||= Builder.new
    end

    def self.match(*args, &block)
      builder.add_matcher(*args, &block)
    end

    def self.mutual(params, opts = {})
      builder.add_constraint(:mutual, params, opts)
    end

    def initialize(params)
      @params = params
      @scope  = self.class.model.unscoped
    end

    def apply_scope
      @scope = yield(@scope)
    end

    def fire_listeners!
      @params.each_pair do |param, value|
        fire_listeners_for!(param, value)
      end
    end

    def verify_constraints!
      builder.constraints.each do |(op, keys, opts)|
        case op
        when :mutual
          exclusives = opts[:exclusive] && Array(opts[:exclusive]) || []
          found_keys = keys.select { |k| params.key?(k) }
          found_excl = exclusives.select { |k| params.key?(k) }

          next if found_keys.empty?
          next if found_keys.empty? && found_excl.empty?
          next if found_keys == keys && found_excl.empty?

          if found_excl.any?
            raise ParamsError, "you specified the following " \
            "#{found_keys.one? ? 'param' : 'params'} in your query: " \
            "#{found_keys.join ', '} and also specified: " \
            "#{found_excl.join ', '} but they are mutually exclusive"
          end

          raise ParamsError, "you specified the following " \
            "#{found_keys.one? ? 'param' : 'params'} in your query: " \
            "#{found_keys.join ', '} but failed to specify: " \
            "#{(keys - found_keys).join(', ')}"
        end
      end
    end

    def to_scope
      verify_constraints!
      fire_listeners!
      @scope
    end

    protected

    def builder
      self.class.builder
    end

    def fire_listeners_for!(raw_param, value)
      param = raw_param.to_s

      builder.listeners.each do |(op, matcher, block)|
        base_param = case op
        when :eq
          next unless param == matcher
          param
        when :start
          next unless param.start_with?(matcher)
          param.sub(matcher, '')
        when :end
          next unless param.end_with?(matcher)
          param.chomp(matcher)
        when :start_end
          starts, ends = *matcher
          next unless param.start_with?(starts) && param.end_with?(ends)
          param.sub(starts, '').chomp(ends)
        end

        instance_exec(value, base_param.to_sym, &block)
      end
    end
  end
end
