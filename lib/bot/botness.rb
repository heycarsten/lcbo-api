module Bot
  module Botness

    def self.included(mod)
      mod.extend(ClassMethods)
    end

    module ClassMethods
      def run
      end
    end

  end
end
