module Mongoid
  module Archive

    extend ActiveSupport::Concern

    included do
      Object.const_set(:"#{self}Update", Class.new {
        include Mongoid::Document
        embedded_in :"#{self.to_s.downcase}", :inverse_of => :updates
      })
      self.archive_doc = Object.const_get(:"#{self}Update")
      embeds_many :updates, :class_name => self.archive_doc.to_s do
        def by_key_value(key, value)
          @target.select { |update| update.attributes[key.to_s] == value }
        end
      end
      before_save :archive_changes
    end

    module ClassMethods
      attr_accessor :archive_target
      attr_accessor :archive_fields
      attr_accessor :archive_doc

      def archive(target, fields)
        self.archive_target = target.to_s
        self.archive_fields = ([target.to_s] + fields.map(&:to_s))
        self.archive_fields.each do |name|
          source = self.fields[name]
          opts = {}
          opts[:type] = source.type
          opts[:default] = source.default
          self.archive_doc.field(name.to_sym, opts)
        end
      end
    end

    def archive_target
      self.class.archive_target
    end

    def archive_fields
      self.class.archive_fields
    end

    def archive_doc
      self.class.archive_doc
    end

    def archived_attributes
      archive_fields.reduce({}) do |hsh, field|
        value = (old = attribute_was(field)) ? old : attributes[field]
        hsh.merge(field => value)
      end
    end

    def archived_target_changed?
      attribute_changed?(archive_target)
    end

    def archived_fields_changed?
      archive_fields.any? { |f| attribute_changed?(f) }
    end

    def archive_update
      key   = archive_target
      value = archived_attributes[key]
      if (update = updates.by_key_value(key, value).first)
        update.update_attributes(archived_attributes)
      else
        create_archive_update
      end
    end

    def create_archive_update
      self.updates << self.archive_doc.new(self.archived_attributes)
    end

    def archive_changes
      if archived_target_changed?
        create_archive_update
      elsif archived_fields_changed?
        archive_update
      end
    end

  end
end
