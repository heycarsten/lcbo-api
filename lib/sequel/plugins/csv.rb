module Sequel
  module Plugins
    module CSV

      module ClassMethods
        def as_csv(hsh, include_header = false)
          row = public_fields.map { |f| hsh[f] }
          if include_header
            a = []
            a << public_fields
            a << row
            a
          else
            row
          end
        end
      end

    end
  end
end
