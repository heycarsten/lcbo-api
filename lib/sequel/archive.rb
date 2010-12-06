module Sequel
  module Archive

    extend ActiveSupport::Concern

    module ClassMethods
      attr_reader :archive_index_attr
      attr_reader :archive_attributes

      def archive(index_attr, attrs)
        @archive_index_attr = index_attr
        @archive_attributes = attrs.push(index_attr)
        Object.const_set(:"#{self}Revision", Class.new(Sequel::Model))
        Object.const_get(:"#{self}Revision").tap do |rev|
          if respond_to?(:primary_keys)
            rev.set_primary_keys(*[index_attr].concat(primary_keys))
            rev.belongs_to(to_s.underscore.to_sym, :foreign_key => primary_keys)
            has_many(:revisions, :class_name => rev.to_s, :foreign_key => primary_keys)
          else
            rev.set_primary_keys(index_attr, :"#{to_s.underscore}_id")
            rev.belongs_to(to_s.underscore.to_sym)
            has_many(:revisions, :class_name => rev.to_s)
          end
        end
      end
    end

    module InstanceMethods
      def archived_attributes
        Hash[self.class.archive_attributes.map { |att| [att, send(att)] }]
      end

      def commit
        before_commit if respond_to?(:before_commit)
        self.class.archive_index_attr.tap do |key|
          if (rev = revisions.where(key => send(key)).first)
            rev.update_attributes(archived_attributes)
          else
            revisions.create(archived_attributes)
          end
        end
        after_commit if respond_to?(:after_commit)
      end
    end

  end
end
