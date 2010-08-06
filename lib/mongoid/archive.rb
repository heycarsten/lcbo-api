module Mongoid
  module Archive

    extend ActiveSupport::Concern

    included do
      Object.const_set(:"#{self}Update", Class.new {
        include Mongoid::Document
        embedded_in :"#{self.to_s.downcase}", :inverse_of => :updates
      })
      self.archive_doc = Object.const_get(:"#{self}Update")
      embeds_many :updates, :class_name => self.archive_doc.to_s
    end

    module ClassMethods
      attr_accessor :archive_target
      attr_accessor :archive_fields
      attr_accessor :archive_doc

      def archive(target, fields)
        self.archive_target = target
        self.archive_fields = ([target] + fields)
        self.archive_doc.fields = self.archive_fields.reduce({}) do |hsh, name|
          hsh.merge(name.to_s => self.fields[name.to_s])
        end
      end
    end

  end
end
