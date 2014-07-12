module LCBO
  class Parser
    include Parseable

    attr_reader :xml

    def initialize(xml)
      @xml = Nokogiri::XML(xml)
    end

    def self.parse(xml)
      new(xml).as_json
    end

    protected

    def lookup(key)
      node = root.xpath("//#{key}").first
      return unless node
      val = node.content.to_s.strip
      val == '' ? nil : val
    end

    def root
      xml
    end
  end
end
