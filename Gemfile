source 'https://rubygems.org'

gem 'rails',        '4.1.1'
gem 'oj'
gem 'pg'
gem 'pg_search'
gem 'kaminari'
gem 'active_model_serializers', github: 'rails-api/active_model_serializers'
gem 'amatch'
gem 'redis'
gem 'gcoder'
gem 'redcarpet'
gem 'puma'
gem 'sass-rails',   '~> 4.0.3'
gem 'therubyracer', platforms: :ruby
gem 'uglifier'
gem 'skylight'

# Crawler Junk
gem 'excon',         require: false
gem 'amatch',        require: false
gem 'stringex',      require: false
gem 'nokogiri',      require: false
gem 'unicode_utils', require: false
gem 'aws-s3',        require: false, github: 'fnando/aws-s3', ref: 'fef95c2d'

group :development do
  gem 'capistrano',         '~> 3.2.1', require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rvm',     require: false
  gem 'propro',             require: false
  gem 'quiet_assets'
  gem 'pry-rails'
end

group :test, :development do
  gem 'rspec',       '~> 2.99', require: false
  gem 'rspec-rails'
  gem 'fabrication',            require: false
  gem 'awesome_print',          require: 'ap'
end
