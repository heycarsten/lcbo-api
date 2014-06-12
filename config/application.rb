require File.expand_path('../boot', __FILE__)

require 'active_model/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

Bundler.require(*Rails.groups)

module LCBOAPI
  class Application < Rails::Application
    # /lib requires
    require 'query_helper'
    require 'exporter'
    require 'boticus'
    require 'crawler'

    config.generators do |g|
      g.assets false
      g.helper false
      g.view_specs false
    end

    # Don't include default application.(css|js) manifest matcher
    config.assets.precompile -= [/(?:\/|\\|\A)application\.(css|js)$/]
    config.assets.precompile += %w[
      lcboapi.js
      lcboapi.css
    ]
  end

  def self.[](key)
    Rails.application.secrets.send(key)
  end

  def self.recache
    rid = _cache_stamp
    RDB.set('lcboapi:cache_stamp', rid)
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
    ((crawl = Crawl.order(Sequel.desc(:id)).first) && crawl.id) || 0
  end

  def self._cache_stamp
    "#{last_crawl_id}#{revision}"
  end

  def self.cache_stamp
    (rid = RDB.get('lcboapi:cache_stamp')) ? rid : recache
  end
end
