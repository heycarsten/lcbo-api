module Ohm
  module ToHash

    def to_hash(*exclusions)
      attrs = (attributes + counters + [:id] - exclusions)
      attrs.reduce({}) { |hsh, att| hsh.merge(att => send(att)) }
    end
    alias_method :to_h, :to_hash

  end
end
