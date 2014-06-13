source 'https://rubygems.org'

gem 'rails',       '4.1.1'
gem 'oj'
gem 'pg'
gem 'sequel'
gem 'sequel_pg',   require: 'sequel'
gem 'amatch'
gem 'stringex'
gem 'redis'
gem 'gcoder'
gem 'lcbo',        '1.5.0'
gem 'redcarpet'
gem 'aws-s3',      require: false, github: 'fnando/aws-s3', ref: 'fef95c2d'
gem 'puma'
gem 'sass-rails',   '~> 4.0.3'
gem 'therubyracer', platforms: :ruby
gem 'uglifier'
gem 'skylight'

group :development do
  gem 'capistrano',         '~> 3.2.1', require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rvm',     require: false
  gem 'propro',             require: false
  gem 'quiet_assets'
  gem 'awesome_print'
  gem 'pry-rails'
end

group :test, :development do
  gem 'rspec',            '~> 2.99'
  gem 'rspec-rails'
  gem 'fabrication',      require: false
  gem 'database_cleaner', github: 'bmabey/database_cleaner'
end
