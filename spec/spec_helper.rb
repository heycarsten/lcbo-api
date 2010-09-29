ENV['RAILS_ENV'] ||= 'test'

require 'minitest/spec'
require File.expand_path("../../config/environment", __FILE__)
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

MiniTest::Unit.autorun
