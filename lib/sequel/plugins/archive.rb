module Sequel
  module Plugins
    module Archive

      def self.configure(model, opts = {})
        pair = opts.first
        unless pair
          raise ArgumentError, "No target attribute specified, try:\n\n" \
          "plugin :archive, :index_attr => [:attr1, :attr2, ...]"
        end
        index_attr, attrs = *pair
        case
        when !index_attr
          raise ArgumentError, "No index attribute was specified, try:\n\n" \
          "plugin :archive, :index_attr => [:attr1, :attr2, ...]"
        when !attrs.is_a?(Array)
          raise ArgumentError, "Attributes is not array, try:\n\n" \
          "plugin :archive, :#{index_attr} => [:attr1, :attr2, ...]"
        when attrs.size > 0
          raise ArgumentError, "No archived attributes, try:\n\n" \
          "plugin :archive, :#{index_attr} => [:attr1, :attr2, ...]"
        end
        model.instance_eval do
          @archive_index_attr = index_attr
          @archive_attributes = attrs.push(index_attr)
        end
        Object.const_set(:"#{model}Revision", Class.new(Sequel::Model))
        Object.const_get(:"#{model}Revision").tap do |rev|
          rev.many_to_one(model.table_name)
          rev.one_to_many(:revisions, :class => rev.to_s)
        end
      end

      module ClassMethods
        attr_reader :archive_index_attr
        attr_reader :archive_attributes
      end

      module InstanceMethods
        def archived_attributes
          Hash[self.class.archive_attributes.map { |att| [att, send(att)] }]
        end

        def commit
          before_commit if respond_to?(:before_commit)
          revisions.create(archived_attributes)
          after_commit if respond_to?(:after_commit)
        end
      end

    end
  end
end
