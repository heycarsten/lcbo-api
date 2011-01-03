module Sequel

  class NotFoundError < Error; end

  module Plugins
    module ExceptableFind

      module ClassMethods
        def find!(*args)
          if (instance = self[*args])
            instance
          else
            raise Sequel::NotFoundError, "No record was found for #{args.inspect}"
          end
        end
      end

    end
  end
end
