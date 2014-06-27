require 'excon'

Excon.defaults[:headers] = {
  'User-Agent' => 'LCBO API - http://lcboapi.com [6ef70a]'
}

module LCBO
  BASE_URL     = 'http://stage.lcbo.com/lcbo-webapp/'
  NUM_PRODUCTS = 15_000

  class Error < StandardError; end
  class NotFoundError < Error; end
  class BadRequestError < Error; end
  class DafuqError < Error; end

  autoload :Util,             'lcbo/util'
  autoload :Parser,           'lcbo/parser'
  autoload :ProductParser,    'lcbo/product_parser'
  autoload :StoreParser,      'lcbo/store_parser'
  autoload :ProductIdsParser, 'lcbo/product_ids_parser'
  autoload :StoreInventoriesParser, 'lcbo/store_inventories_parser'

  module_function

  def store(id)
    xml = get("storedetail.do?locationNumber=#{id}")
    StoreParser.parse(xml)
  end

  def product(id)
    xml = get("productdetail.do?itemNumber=#{id}")
    ProductParser.parse(xml)
  end

  def store_inventories(id)
    xml = get("productsearch.do?locationNumber=#{id}&numProducts=#{NUM_PRODUCTS}")
    StoreInventoriesParser.parse(xml)[:inventories]
  end

  def product_ids
    xml = get("productsearch.do?numProducts=#{NUM_PRODUCTS}")
    ProductIdsParser.parse(xml)[:ids]
  end

  def get(path)
    response = Excon.get(BASE_URL + path)

    case response.status
    when 200
      response.body
    when 404
      raise NotFoundError, "unable to find: #{path}"
    else
      raise BadRequestError, "#{path} returned status #{response.status}"
    end
  rescue Excon::Errors::Timeout => e
    raise TimeoutError, "request timed out: #{path}"
  end
end
