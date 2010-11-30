module Ohm
  module Archive

    def self.included(host)
      Object.const_set(:"#{host}Revision", Class.new(Ohm::Model))
      model = Object.const_get(:"#{host}Revision")
      model.send(:include, Ohm::Typecast) if host.include?(Ohm::Typecast)
      model.send(:include, Ohm::ToHash) if host.include?(Ohm::ToHash)

      host.send(:instance_variable_set, :@attribute_arguments, [])
      host.send(:instance_variable_set, :@archive_rev_model, model)
      host.collection(:revisions, model)

      host.extend(ClassMethods)
    end

    module ClassMethods
      attr_reader :archive_index_attr
      attr_reader :archive_attributes
      attr_reader :archive_rev_model

      def attribute(*args)
        @attribute_arguments << args
        super(*args)
      end

      def copy_attributes(dest)
        @attribute_arguments.
          select { |args| @archive_attributes.include?(args[0]) }.
          each   { |args| dest.attribute(*args) }
      end

      def archive(index_attr, attrs)
        @archive_index_attr = index_attr
        @archive_attributes = attrs.push(index_attr)
        copy_attributes @archive_rev_model
        @archive_rev_model.index(index_attr)
        @archive_rev_model.reference(self.to_reference, self)
      end
    end

    def archived_attributes
      self.class.archive_attributes.reduce({}) do |hsh, key|
        hsh.merge(key => send(key))
      end
    end

    def commit
      before_commit if respond_to?(:before_commit)
      self.class.archive_index_attr.tap do |key|
        if (rev = revisions.find(key => send(key)).first)
          rev.update_attributes(archived_attributes)
          rev.save
        else
          revisions << self.class.archive_rev_model.create(archived_attributes)
        end
      end
      after_commit if respond_to?(:after_commit)
    end

  end
end
