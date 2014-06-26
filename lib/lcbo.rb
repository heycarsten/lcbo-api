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
  class TimeoutError < Error; end

  autoload :Util,          'lcbo/util'
  autoload :Parser,        'lcbo/parser'
  autoload :ProductParser, 'lcbo/product_parser'
  autoload :StoreParser,   'lcbo/store_parser'

  # Get all products
  # 

  # Get product details
  # http://stage.lcbo.com/lcbo-webapp/productdetail.do?itemNumber=612804

  # Get store details
  # http://stage.lcbo.com/lcbo-webapp/storedetail.do?locationNumber=511

  # Get all products and inventory levels at a store
  # http://stage.lcbo.com/lcbo-webapp/productsearch.do?locationNumber=534&numProducts=15000

  module_function

  def store(id)
    StoreParser.parse(get("storedetail.do?locationNumber=#{id}"))
  end

  def product(id)
    ProductParser.parse(get("productdetail.do?itemNumber=#{id}"))
  end

  def products_list
    xml = get("productsearch.do?numProducts=#{NUM_PRODUCTS}")
    xml.xpath('//products//product//itemNumber').map { |n| n.content.to_i }
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
