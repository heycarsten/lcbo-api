module Sequel
  module Plugins
    module Archive

      def self.configure(model, opts = {})
        index_attr, attrs = *opts.first
        model.instance_variable_set(:@archive_index_attr, index_attr)
        model.instance_variable_set(:@archive_attributes, attrs.push(index_attr))
        Object.const_set(:"#{model}Revision", Class.new(::Sequel::Model))
        Object.const_get(:"#{model}Revision").tap do |rev|
          rev.set_dataset(rev.implicit_table_name)
          modname = model.to_s.underscore.to_sym
          rev.many_to_one(modname)
          if (pk = model.primary_key).is_a?(Array)
            model.one_to_many(:revisions, :class => rev, :key => pk)
          else
            model.one_to_many(:revisions, :class => rev)
          end
        end
      end

      module ClassMethods
        attr_reader :archive_index_attr
        attr_reader :archive_attributes
      end

      module InstanceMethods
        def _archive_fk_attributes
          if self.class.primary_key.is_a?(Array)
            Hash[self.class.primary_key.map { |att| [att, send(att)] }]
          else
            { :"#{self.class.to_s.underscore}_id" => pk }
          end
        end

        def _archive_attributes
          Hash[self.class.archive_attributes.map { |att| [att, send(att)] }]
        end

        def commit
          before_commit if respond_to?(:before_commit)
          begin
            revisions_dataset.insert(_archive_fk_attributes.merge(_archive_attributes))
          rescue Sequel::DatabaseError
            revisions_dataset.
              filter(self.class.archive_index_attr => send(self.class.archive_index_attr)).
              update(_archive_attributes)
          end
          after_commit if respond_to?(:after_commit)
        end
      end

    end
  end
end
