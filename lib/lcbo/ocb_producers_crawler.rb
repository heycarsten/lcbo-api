module LCBO
  class OCBProducersCrawler
    include Parseable

    ENDPOINT = 'http://www.ontariocraftbrewers.com/breweriesList.php'
    BREWERY_RE = %r{
      brewery\ farm|
      brewing\ company|
      brewing\ co|
      craft\ brewery|
      brewhouse|
      brewers|
      brewing|
      beer\ co
    }x

    def self.normalize_name(name)
      name.downcase.
        sub(BREWERY_RE, 'brewery').
        gsub(/\'|\./, '').
        gsub(/(co|ltd|inc)(\Z| )/, '').
        gsub(/[ ]+/, ' ').strip
    end

    def self.parse
      new.as_json
    end

    def initialize
      html = LCBO.get(ENDPOINT)
      @doc = Nokogiri::HTML(html)
    end

    field :producers do
      a = []

      @doc.css('#brewery-list .menu ul li a span').each do |node|
        name = node.content.strip

        a << {
          name: name,
          normalized_name: OCBProducersCrawler.normalize_name(name)
        }
      end

      a
    end
  end
end
