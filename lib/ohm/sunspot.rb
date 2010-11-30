module Ohm
  module Sunspot

    def self.included(host)
      host.extend(ClassMethods)
      host.send(:include, InstanceMethods)
    end

    module ClassMethods
      def sunspot(&block)
        ::Sunspot.setup(self, &block)
      end

      def search(&block)
        ::Sunspot.search(self, &block)
      end
    end

    module InstanceMethods
      def after_commit
        ::Sunspot.index(self)
      end
    end

  end
end
