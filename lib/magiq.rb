require 'ostruct'

module Magiq
  class Error < StandardError; end
  class ParamsError < Error; end

  DEFAULT_CONFIG = OpenStruct.new(
    page_size: 50
  )

  autoload :Builder, 'magiq/builder'
  autoload :Query,   'magiq/query'

  module_function

  def config
    @config ||= DEFAULT_CONFIG.dup
  end

  def configure
    yield(config)
  end
end
