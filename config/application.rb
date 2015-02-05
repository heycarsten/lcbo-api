require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LCBOAPI
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    require 'base62'
    require 'token'
    require 'secure_compare'
    require 'lcbo'
    require 'magiq'
    require 'geo_scope'
    require 'redis_abuse'
    require 'api_constraint'
    require 'v1/query_helper'
    require 'v1/exporter'
    require 'boticus'
    require 'crawler'
    require 'image_cacher'

    config.generators do |g|
      g.assets false
      g.helper false
      g.view_specs false
    end

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
  end

  def self.[](key)
    Rails.application.secrets.send(key)
  end

  def self.recache
    rid = _cache_stamp
    $redis.set('lcboapi:cache_stamp', rid)
    rid
  end

  def self.flush
    recache
    ENV['RAILS_ASSET_ID'] = cache_stamp
  end

  def self.revfile
    (Rails.root + 'REVISION').to_s
  end

  def self.has_revfile?
    File.exists?(revfile)
  end

  def self.revision
    if has_revfile?
      File.read(revfile).strip[0,7]
    else
      Time.now.to_i.to_s
    end
  end

  def self.last_crawl_id
    if (crawl = Crawl.order(id: :desc).first)
      crawl.id
    else
      0
    end
  end

  def self._cache_stamp
    "#{last_crawl_id}#{revision}"
  end

  def self.cache_stamp
    if (rid = $redis.get('lcboapi:cache_stamp'))
      rid
    else
      recache
    end
  end
end
