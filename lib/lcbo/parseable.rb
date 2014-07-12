require 'nokogiri'

module LCBO
  module Parseable
    extend ActiveSupport::Concern
    module ClassMethods
      def fields
        @fields ||= []
      end

      def field(name, &block)
        name = name.to_sym

        if fields.include?(name)
          raise ArgumentError, "#{name.inspect} is already a defined field"
        end

        fields << name

        define_method(name, &block)
      end
    end

    def as_json
      @as_json ||= begin
        before_parse

        hsh = self.class.fields.reduce({}) { |h, field|
          h.merge(field => __send__(field))
        }

        after_parse

        hsh
      end
    end

    protected

    def css(selector)
      @doc.css(selector.to_s)
    end

    def xpath(selector)
      @doc.xpath(selector.to_s)
    end

    def before_parse
    end

    def after_parse
    end

    def util
      Util
    end
  end
end
