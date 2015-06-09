source 'https://rubygems.org'

gem 'rails',          '4.2.1'
gem 'responders'
gem 'oj'
gem 'pg'
gem 'pg_search'
gem 'bcrypt'
gem 'kaminari'
gem 'active_model_serializers', github: 'rails-api/active_model_serializers', ref: '0-9-stable'
gem 'redis'
gem 'gcoder'
gem 'puma'
gem 'jquery-rails'
gem 'bootstrap-sass', '~> 3.3.3'
gem 'sass-rails',     '~> 5.0.1'
gem 'therubyracer',   platforms: :ruby
gem 'uglifier'
#gem 'skylight',       '~> 0.6.0'
#gem 'honeybadger',    '~> 2.0.6'
gem 'stripe',         github: 'stripe/stripe-ruby'

# Crawler Junk
gem 'excon',         require: false
gem 'amatch',        require: false
gem 'stringex',      require: false
gem 'nokogiri',      require: false
gem 'unicode_utils', require: false
gem 'aws-s3',        require: false, github: 'fnando/aws-s3', ref: 'fef95c2d'

group :development do
  gem 'capistrano',         '~> 3.3.5'
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
  gem 'quiet_assets'
  gem 'pry-rails'
  gem 'spring'
  gem 'spring-commands-rspec'
end

group :test, :development do
  gem 'rspec-rails'
  gem 'fabrication',   require: false
  gem 'awesome_print', require: 'ap'
end
