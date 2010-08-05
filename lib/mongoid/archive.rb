module Mongoid
  module Archive

    extend ActiveSupport::Concern

    module ClassMethods
      attr_accessor :archive_primary_field
      attr_accessor :archive_fields

      def archive(primary_field, secondary_fields)
        self.archive_primary_field = primary_field
        self.archive_fields = ([primary_field] + secondary_fields)

        Object.const_set(:"#{self}Update", Class.new {
          include Mongoid::Document
          embedded_in :"#{self.to_s.downcase}", :inverse_of => :updates
        })

        update_doc = Object.const_get(:"#{self}Update")

        update_doc.fields = self.archive_fields.reduce({}) do |hsh, name|
          hsh.merge(name.to_s => self.fields[name.to_s])
        end

        embeds_many :updates, :class_name => update_doc.to_s
      end
    end

  end
end
