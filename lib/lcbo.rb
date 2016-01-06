require 'excon'

Excon.defaults[:headers] = {
  'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.52 Safari/537.36'
}

module LCBO
  API_BASE_URL = 'http://www.foodanddrink.ca/lcbo-webapp/'
  NUM_PRODUCTS = 15_000

  class Error < StandardError; end
  class NotFoundError < Error; end
  class BadRequestError < Error; end
  class DafuqError < Error; end

  autoload :Util,                      'lcbo/util'
  autoload :Parseable,                 'lcbo/parseable'
  autoload :Parser,                    'lcbo/parser'

  autoload :OCBProducersCrawler,       'lcbo/ocb_producers_crawler'
  autoload :ProductParser,             'lcbo/product_parser'
  autoload :CatalogProductCrawler,     'lcbo/catalog_product_crawler'
  autoload :StoreIdsParser,            'lcbo/store_ids_parser'
  autoload :StoreParser,               'lcbo/store_parser'
  autoload :ProductsParser,            'lcbo/products_parser'
  autoload :ProductInventoriesCrawler, 'lcbo/product_inventories_crawler'
  autoload :StoreInventoriesParser,    'lcbo/store_inventories_parser'

  module_function

  def store_ids
    xml = get('http://www.foodanddrink.ca/lcbo-webapp/storequery.do?searchType=' \
      'proximity&longitude=-79.4435649&latitude=43.6581718&numstores=900')
    StoreIdsParser.parse(xml)[:ids]
  end

  def store(id)
    xml = api("storedetail.do?locationNumber=#{id}")
    StoreParser.parse(xml)
  end

  def product(id)
    xml = api("productdetail.do?itemNumber=#{id}")
    ProductParser.parse(xml)
  end

  def catalog_product(id)
    CatalogProductCrawler.parse(id)
  end

  # Get all product inventories for an entire store
  def store_inventories(id)
    xml = api("productsearch.do?locationNumber=#{id}&numProducts=#{NUM_PRODUCTS}")
    StoreInventoriesParser.parse(xml)[:inventories]
  end

  # Get all store inventory levels for a specific product
  def product_inventories(id)
    ProductInventoriesCrawler.crawl(id)
  end

  def products
    xml = api("productsearch.do?numProducts=#{NUM_PRODUCTS}")
    ProductsParser.parse(xml)[:products]
  end

  def product_images(id)
    id = id.to_s.rjust(6, '0')

    thumb_url = "http://www.lcbo.com/content/dam/lcbo/products/#{id}.jpg/" \
      "jcr:content/renditions/cq5dam.thumbnail.319.319.png"
    full_url  = "http://www.lcbo.com/content/dam/lcbo/products/#{id}.jpg/" \
      "jcr:content/renditions/cq5dam.web.1280.1280.jpeg"

    if Excon.head(thumb_url).status == 200
      { image_url:       full_url,
        image_thumb_url: thumb_url }
    else
      nil
    end
  end

  def api(path)
    get(API_BASE_URL + path)
  end

  def get(url)
    response = Excon.get(url)

    case response.status
    when 200
      response.body
    when 404
      raise NotFoundError, "unable to find: #{url}"
    else
      raise BadRequestError, "#{url} returned status #{response.status}"
    end
  rescue Excon::Errors::Timeout => e
    raise TimeoutError, "request timed out: #{url}"
  end
end
