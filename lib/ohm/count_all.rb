module Ohm
  module CountAll
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def self.count_all
        redis["#{key}:*"].size
      end
    end
  end
end
