module Magiq
  class Builder
    END_RNG   = /\}([a-z0-9_]+)\Z/
    START_RNG = /\A([a-z0-9_]+)\{/
    CONSTRAINTS = [:mutual, :exclusive]

    attr_reader :listeners, :constraints, :checks, :params

    def initialize
      @listeners   = []
      @constraints = []
      @checks      = []
      @params      = {}
    end

    def add_listener(params, &block)
      listeners << [params, block]
    end

    def add_check(params, &block)
      checks << [params, block]
    end

    def add_param(name, opts = {})
      params[name.to_sym] = Param.new(name, opts)
    end

    def add_constraint(op, params_arg, opts = {})
      if !CONSTRAINTS.include?(op)
        raise ArgumentError, "unknown constraint type: #{op.inspect}"
      end

      params = Array(params_arg)

      if params.size == 1 && !opts[:exclusive]
        raise ArgumentError, "a single parameter can't be mutual unless it " \
          "has an exclusive counterpart"
      end

      params.each do |p|
        constraints << [op, params, opts]
      end
    end
  end
end
