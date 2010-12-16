module Sequel
  module Plugins
    module Archive

      def self.configure(model, index_attr)
        model.instance_variable_set(:@archive_index_attr, index_attr)
      end

      module ClassMethods
        attr_reader :archive_index_attr

        def archive_revisions_table
          :"#{to_s.underscore}_revisions"
        end

        def archive_revisions_dataset
          DB[archive_revisions_table]
        end

        def archive_revisions_columns
          @archive_revisions_columns ||= archive_revisions_dataset.columns
        end

        def archive_columns
          @archive_columns ||= archive_revisions_columns.map do |col|
            if primary_key.is_a?(Array)
              col
            else
              col == :"#{to_s.underscore}_id" ? :id : col
            end
          end
        end

        def commit(crawl_id)
          DB << %{
            INSERT INTO #{ archive_revisions_table }
              (#{ archive_revisions_columns.join(', ') })
            SELECT
              #{ archive_columns.join(', ') }
              FROM #{implicit_table_name}
              WHERE crawl_id = #{crawl_id}
          }
        end
      end

      module InstanceMethods
        def _archive_fk_attributes
          if self.class.primary_key.is_a?(Array)
            Hash[self.class.primary_key.map { |att| [att, send(att)] }]
          else
            { :"#{self.class.to_s.underscore}_id" => pk }
          end
        end

        def revisions
          self.class.archive_revisions_dataset.
            filter(_archive_fk_attributes).
            distinct(self.class.archive_index_attr)
        end
      end

    end
  end
end
