module ActiveRecord
  module Archive

    def self.included(host)
      Object.const_set(:"#{host}Revision", Class.new(ActiveRecord::Base))
      model = Object.const_get(:"#{host}Revision")
      host.send(:instance_variable_set, :@attribute_arguments, [])
      host.send(:instance_variable_set, :@archive_rev_model, model)
      host.has_many(:revisions, :class_name => model.to_s)
      host.extend(ClassMethods)
    end

    module ClassMethods
      attr_reader :archive_index_attr
      attr_reader :archive_attributes
      attr_reader :archive_rev_model

      def archive(index_attr, attrs)
        @archive_index_attr = index_attr
        @archive_attributes = attrs.push(index_attr)
        @archive_rev_model.belongs_to(self.to_s.downcase.to_sym)
      end
    end

    def archived_attributes
      Hash[self.class.archive_attributes.map { |att| [att, send(att)] }]
    end

    def commit
      before_commit if respond_to?(:before_commit)
      self.class.archive_index_attr.tap do |key|
        if (rev = revisions.first(key => send(key)).first)
          rev.update_attributes(archived_attributes)
        else
          revisions.create(archived_attributes)
        end
      end
      after_commit if respond_to?(:after_commit)
    end

  end
end
