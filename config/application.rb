require File.expand_path('../boot', __FILE__)

require 'active_model/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

Bundler.require(*Rails.groups)

module LCBOAPI
  class Application < Rails::Application
    # /lib requires
    require 'geo_scope'
    require 'redis_abuse'
    require 'query_helper'
    require 'exporter'
    require 'boticus'
    require 'crawler'

    config.generators do |g|
      g.assets false
      g.helper false
      g.view_specs false
    end

    config.active_record.schema_format = :sql
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
