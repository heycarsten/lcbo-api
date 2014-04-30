module Sequel
  module Plugins
    module Api

      def self.configure(model, opts = {})
        not_csv_columns  = (opts.delete(:not_csv) || [])
        private_columns  = (opts.delete(:private) || [])
        column_aliases   = (opts.delete(:aliases) || {})
        remapped_columns = (opts.delete(:remap)   || {})

        raise ArgumentError, "options contains unknown keys" if opts.any?

        model.instance_variable_set(:@not_csv_columns,  not_csv_columns)
        model.instance_variable_set(:@private_columns,  private_columns)
        model.instance_variable_set(:@column_aliases,   column_aliases)
        model.instance_variable_set(:@remapped_columns, remapped_columns)
      end

      module ClassMethods
        attr_reader :private_columns, :column_aliases, :not_csv_columns,
          :remapped_columns

        def public_columns
          @public_columns ||= (columns - private_columns)
        end

        def csv_columns
          @csv_columns ||= (public_columns - not_csv_columns)
        end

        def human_csv_columns
          @human_csv_columns ||= begin
            csv_columns.map { |c| c.to_s.gsub('_', ' ').titlecase }
          end
        end

        def api_values(obj)
          hsh = (obj.is_a?(Hash) ? obj : obj.values)
          column_aliases.each_pair { |ksrc, kalias| hsh[kalias] = hsh[ksrc] }
          remapped_columns.each_pair { |from, to| hsh[to] = hsh.delete(from) }
          hsh.except(*private_columns)
        end

        def as_json(obj)
          api_values(obj)
        end

        def as_csv(obj, with_header = false)
          rows = []
          rows << human_csv_columns if with_header
          rows << as_csv_row(obj)
          rows
        end

        def as_csv_row(obj)
          hsh = api_values(obj)
          csv_columns.map { |c| hsh[c] }
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
