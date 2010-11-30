module Ohm
  module Sunspot

    def self.included(host)
      host.send(:include, Ohm::Callbacks)
      host.send(:include, InstanceMethods)
      host.extend(ClassMethods)
      ::Sunspot::Adapters::InstanceAdapter.register(Helper::Adapter, host)
      ::Sunspot::Adapters::DataAccessor.register(Helper::Accessor, host)
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

    module Helper
      class Adapter < ::Sunspot::Adapters::InstanceAdapter
        def id
          @instance.id
        end
      end

      class Accessor < ::Sunspot::Adapters::DataAccessor
        def load(id)
          @clazz[id]
        end
      end
    end

  end
end
