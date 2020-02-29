source 'https://rubygems.org'

gem 'rails',          '5.2.2'
gem 'responders'
gem 'pg'
gem 'pg_search'
gem 'bcrypt'
gem 'kaminari'
gem 'active_model_serializers', git: 'https://github.com/rails-api/active_model_serializers', ref: '0-9-stable'
gem 'redis'
gem 'gcoder'
gem 'puma', '~> 3.12'
gem 'jquery-rails'
gem 'bootstrap-sass', '~> 3' #'~> 3.3.3'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'stripe'          #git: 'https://github.com/stripe/stripe-ruby'
gem 'dotenv-rails'
gem 'bootsnap', '>= 1.1.0', require: false

#gem 'capistrano',         #'~> 3.3.5'
gem 'capistrano-rails'
gem 'capistrano-bundler'
gem 'capistrano-rvm'

# Crawler Junk
gem 'excon',         require: false
gem 'amatch',        require: false
gem 'stringex',      require: false
gem 'nokogiri',      require: false
gem 'unicode_utils', require: false
gem 'aws-sdk',       '~> 2', require: false

group :development do
  gem 'pry-rails'
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'spring-commands-rspec'
end

group :test, :development do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'fabrication',   require: false
  gem 'awesome_print', require: 'ap'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
