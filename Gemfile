source 'https://rubygems.org'
ruby '2.0.0'

gem 'rails',       '3.2.13'
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
gem 'exceptional'
gem 'aws-s3',      require: false
gem 'puma'

group :assets do
  gem 'jquery-rails'
  gem 'sass-rails'
  gem 'therubyracer', require: 'v8'
  gem 'uglifier'
end

group :development do
  gem 'awesome_print'
  gem 'pry-rails'
  gem 'capistrano',     require: false
  gem 'capistrano-ext', require: false
  gem 'rvm-capistrano', require: false
end

group :test, :development do
  gem 'rspec-rails'
  gem 'capybara',    require: false
  gem 'fabrication', require: false
end

group :test do
  gem 'database_cleaner'
end
