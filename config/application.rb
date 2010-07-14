require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'mongoid/railtie'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module LCBOAPI
  class Application < Rails::Application
    # Configure generators values. Many other options are available, be sure to
    # check the documentation.
    config.generators do |g|
      g.test_framework  :rspec
    end

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
  end
end
