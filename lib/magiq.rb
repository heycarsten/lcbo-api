require 'ostruct'

module Magiq
  DEFAULT_CONFIG = OpenStruct.new(
    page_size: 50
  )

  autoload :Builder,   'magiq/builder'
  autoload :Attribute, 'magiq/attribute'

  module_function

  def config
    @config ||= DEFAULT_CONFIG.dup
  end

  def configure
    yield(config)
  end
end
