module LCBO
  class ProductInventoriesCrawler
    include Parseable

    STORE_ID_RNG = /STORE=([0-9]+)/i
    BASE_URL = 'http://www.vintages.com/lcbo-ear/vintages/product/' \
      'inventory/searchResults.do?language=EN&itemNumber='
    INVENTORY_TR_SEL = 'form[name="inventoryresults"] table[border="0"]' \
      '[width="100%"][cellpadding="5"] tr'

    def self.crawl(id)
      new(id).as_json[:inventories]
    end

    def initialize(id)
      @id  = id
      @doc = Nokogiri::HTML(LCBO.get("#{BASE_URL}#{id}"))
    end

    field :inventories do
      a = []

      @doc.css(INVENTORY_TR_SEL).each do |tr|
        next unless (cells = tr.css('td p')).size == 4

        store_id    = cells[1].css('a')[0][:href].match(STORE_ID_RNG)[1]
        reported_on = cells[2].content.strip
        quantity    = cells[3].content.strip

        a << {
          store_id:    store_id.to_i,
          reported_on: util.parse_date(reported_on),
          quantity:    quantity.to_i
        }
      end

      a
    end
  end
end
