module Ohm
  module Rails

    def self.included(host)
      host.send(:include, InstanceMethods)
      host.extend(ClassMethods)
    end

    module ClassMethods
      def get(id)
        if (obj = self[id])
          raise Ohm::Model::MissingID, "Can't find #{self} by: #{id.inspect}"
        else
          obj
        end
      end
    end

    module InstanceMethods
      def to_param
        id.to_s
      end
    end

  end
end
