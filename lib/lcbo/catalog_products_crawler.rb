require 'excon'
require 'nokogiri'

module LCBO
  class CatalogProductsCrawler
    PER     = 50 # 50 is the max
    URL     = "http://www.lcbo.com/webapp/wcs/stores/servlet/CategoryNavigationResultsView?pageSize=#{PER}&manufacturer=&searchType=&resultCatEntryType=&catalogId=10001&categoryId=&langId=-1&pageName=&storeId=10151&sType=SimpleSearch&filterFacet=&metaData="
    ID_PART = /\/([0-9]+)\Z/
    AIR_MILES_PART = /\A([0-9]+) Bonus/i

    DATA = {
      contentBeginIndex: 0,
      productBeginIndex: 0,
      beginIndex: 0,
      orderBy: 2,
      isHistory: 'false',
      categoryPath: '//',
      pageView: '',
      resultType: 'products',
      orderByContent: '',
      searchTerm: '',
      facet: '',
      minPrice: '',
      maxPrice: '',
      storeId: '10151',
      catalogId: '10001',
      langId: '-1',
      fromPage: '',
      objectId: '',
      requesttype: 'ajax'
    }

    HEADERS = {
      'Origin'           => 'http://www.lcbo.com',
      'Content-Type'     => 'application/x-www-form-urlencoded',
      'X-Requested-With' => 'XMLHttpRequest',
      'Referer'          => 'http://www.lcbo.com/lcbo/search?searchTerm='
    }

    attr_reader :products, :total
    attr_accessor :page

    def self.crawl
      puts 'Crawling product catalog...'
      crawler = new
      crawler.crawl
      puts
      crawler.products
    end

    def self.crawl_page(page)
      crawler = new
      crawler.page = page
      crawler.crawl_page!
      crawler
    end

    def initialize
      @products = []
      @page  = 1
      @total = nil
    end

    def crawl_page!
      index  = (page * PER) - PER
      data   = DATA.merge(beginIndex: index, productBeginIndex: index)
      params = URI.encode_www_form(data)
      resp   = Excon.post(URL, body: params, headers: HEADERS)
      doc    = Nokogiri::HTML(resp.body)

      products = doc.css('.products > .product').map do |node|
        parse_product_node(node)
      end

      @total ||= doc.css('.results-count .count')[0].content.to_i
      @products.concat(products)
    end

    def dot
      STDOUT.print('.')
      STDOUT.flush
    end

    def increment_page!
      @page += 1
    end

    def total_pages
      @total_pages ||= (total / PER.to_f).round
    end

    def util
      Util
    end

    def crawl
      loop do
        crawl_page!
        dot
        increment_page!

        break if page > 10 #total_pages
      end
    end

    def parse_product_node(node)
      hsh  = {}
      href = node.css('.product-name a')[0][:href].strip
      id   = href.match(ID_PART)[1].to_i

      was_price = if (was_node = node.css('.was-price')[0])
        util.parse_dollars(was_node.content)
      end

      price = util.parse_dollars(node.css('.price')[0].content)

      bonus_reward_miles = if (air_node = node.css('.air-miles')[0])
        am = air_node.content.to_s.strip
        am.blank? ? 0 : am.match(AIR_MILES_PART)[1].to_i
      else
        0
      end

      if was_price
        regular_price_in_cents = (was_price * 100).to_i
        price_in_cents         = (price * 100).to_i
      else
        regular_price_in_cents = (price * 100).to_i
        price_in_cents         = regular_price_in_cents
      end

      lto_savings_in_cents = regular_price_in_cents - price_in_cents

      { id:                                  id,
        href:                                ('http://www.lcbo.com' + href),
        bonus_reward_miles:                  bonus_reward_miles,
        has_bonus_reward_miles:              bonus_reward_miles != 0,
        price_in_cents:                      price_in_cents,
        regular_price_in_cents:              regular_price_in_cents,
        limited_time_offer_savings_in_cents: lto_savings_in_cents,
        has_limited_time_offer:              lto_savings_in_cents != 0 }
    end
  end
end
