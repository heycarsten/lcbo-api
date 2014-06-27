require 'nokogiri'

module LCBO
  class Parser
    attr_reader :xml

    def initialize(xml)
      @xml = Nokogiri::XML(xml)
    end

    def self.parse(xml)
      new(xml).as_json
    end

    def self.fields
      @fields ||= []
    end

    def self.field(name, &block)
      name = name.to_sym

      if fields.include?(name)
        raise ArgumentError, "#{name.inspect} is already a defined field"
      end

      fields << name

      define_method(name, &block)
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

    def before_parse
    end

    def after_parse
    end

    def lookup(key)
      node = root.xpath("//#{key}").first
      return unless node
      val = node.content.to_s.strip
      val == '' ? nil : val
    end

    def root
      xml
    end

    def util
      Util
    end
  end
end
