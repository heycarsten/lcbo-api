module Magiq
  class Builder
    END_RNG   = /\}([a-z0-9_]+)\Z/
    START_RNG = /\A([a-z0-9_]+)\{/
    CONSTRAINTS = [:mutual, :exclusive]

    attr_reader :listeners, :constraints

    def initialize
      @listeners   = []
      @constraints = []
    end

    def add_matcher(macro, &block)
      case macro
      when Symbol
        listeners << [:eq, macro.to_s, block]
      when String
        ends   = $1 if macro =~ END_RNG
        starts = $1 if macro =~ START_RNG

        if ends && starts
          listeners << [:start_end, [starts, ends], block]
        elsif ends
          listeners << [:end, ends, block]
        elsif starts
          listeners << [:start, starts, block]
        else
          raise ArgumentError, 'expected matcher macro to contain ' \
            'placeholder {param}'
        end
      else
        raise ArgumentError, 'expected matcher to be string or symbol'
      end
    end

    def add_constraint(op, params_arg, opts = {})
      if !CONSTRAINTS.include?(op)
        raise ArgumentError, "unkown constraint type: #{op.inspect}"
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
