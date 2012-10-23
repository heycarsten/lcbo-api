require File.expand_path('../boot', __FILE__)

#require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'sprockets/railtie'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(assets: %w[development test]))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module LCBOAPI
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Generator config
    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :fabrication
      g.javascripts false
      g.stylesheets false
    end

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W[#{config.root}/lib]

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'UTF-8'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    # config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Define asset manifests
    config.assets.precompile -= %w[
      application.css
      application.js
    ]
    config.assets.precompile += %w[
      lcboapi.css
      lcboapi.js
    ]

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
  end

  def self.[](value)
    @config ||= YAML.load_file((Rails.root + 'config' + 'lcboapi.yml').to_s)
    @config[value]
  end
end
