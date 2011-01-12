module Sequel
  module Plugins
    module API

      def self.configure(model, opts = {})
        not_csv_columns = (opts.delete(:not_csv) || [])
        private_columns = (opts.delete(:private) || [])
        public_columns  = (opts.delete(:public)  || [])
        column_aliases  = (opts.delete(:aliases) || [])

        model.instance_variable_set(:@not_csv_columns, not_csv_columns)
        model.instance_variable_set(:@private_columns, private_columns)
        model.instance_variable_set(:@public_columns,  public_columns)
        model.instance_variable_set(:@column_aliases,  column_aliases)
      end

      module ClassMethods
        class << self
          attr_reader :private_columns, :column_aliases, :not_csv_columns
        end

        def public_columns
          @public_columns ||= (columns - private_columns)
        end

        def api_values(obj)
          hsh = (obj.is_a?(Hash) ? obj : obj.values)
          column_aliases.each_pair { |ksrc, kalias| hsh[kalias] = hsh[ksrc] }
          hsh.except(*private_columns)
        end

        def as_json(obj)
          api_values(obj)
        end

        def as_csv(obj, with_header = false)
          hsh = api_values(obj).except(*not_csv_columns)
          row = public_columns.map { |f| hsh[f] }
          if with_header
            a = []
            a << public_columns
            a << row
            a
          else
            row
          end
        end
      end

      module InstanceMethods
        def as_json
          self.class.as_json(values)
        end

        def as_csv(with_header = false)
          self.class.as_csv(values, with_header)
        end
      end

    end
  end
end
