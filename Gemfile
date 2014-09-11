source 'https://rubygems.org'

gem 'rails',        '4.1.6'
gem 'oj'
gem 'oj_mimic_json'
gem 'pg'
gem 'pg_search'
gem 'bcrypt'
gem 'kaminari'
gem 'active_model_serializers', github: 'rails-api/active_model_serializers', ref: '0-9-stable'
gem 'redis'
gem 'gcoder'
gem 'puma'
gem 'sass-rails',   '~> 4.0.3'
gem 'therubyracer', platforms: :ruby
gem 'uglifier'
gem 'skylight'
gem 'honeybadger'

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
  gem 'spring'
  gem 'spring-commands-rspec'
end

group :test, :development do
  gem 'rspec-rails'
  gem 'fabrication',            require: false
  gem 'awesome_print',          require: 'ap'
end
