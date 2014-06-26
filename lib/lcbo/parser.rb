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

    def as_json
      @as_json ||= self.class.fields.reduce({}) do |h, field|
        h.merge(field => __send__(field))
      end
    end
  end
end
