require 'yaml'
require 'sequel'
include Rake::DSL

module Sequel
  module Rails

    CONFIG = YAML.load_file('config/database.yml')

    def self.getenv(env = nil)
      if env.to_s.strip != ''
        env
      else
        ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
      end.to_sym
    end

    def self.config(env = nil)
      CONFIG[getenv(env)]
    end

    def self.dbs
      @dbs ||= {}
    end

    def self.db(env = nil)
      dbs[getenv(env)] ||= ::Sequel.connect(config(env))
    end

    def self.drop(env = nil)
      config(env).tap do |c|
        system "dropdb #{c[:database]}"
      end
    end

    def self.create(env = nil)
      config(env).tap do |c|
        system "createdb -E #{c[:encoding]} #{c[:database]}"
      end
    end

    namespace :db do
      desc "Output schema information for current environment (#{getenv})"
      task :info do
        require 'pp'
        pp db[:schema_info].last
      end

      desc "Run migrator for current environment (#{getenv})"
      task :migrate, [:version] do |t, args|
        require 'sequel/extensions/migration'
        opts = {}
        opts[:target] = args[:version].to_i if args[:version]
        ::Sequel::Migrator.run(db, 'db/migrations', opts)
      end

      desc "Drop database for current environment (#{getenv})"
      task :drop do
        drop
      end

      desc "Drop database for all environments in database.yml"
      task :drop_all do
        CONFIG.keys.each { |env| drop(env) }
      end

      desc "Create database for current environment (#{getenv})"
      task :create do
        create
      end

      desc "Create database for all environments in database.yml"
      task :create_all do
        CONFIG.keys.each { |env| create(env) }
      end
    end

  end
end
