source :rubygems

gem 'rails',       '3.2.11'
gem 'rack',        '1.4.5'
gem 'pg'
gem 'sequel'
gem 'sequel_pg',   require: 'sequel'
gem 'yajl-ruby',   require: 'yajl'
gem 'amatch'
gem 'stringex'
gem 'redis'
gem 'dalli'
gem 'rack-cache',  require: 'rack/cache'
gem 'gcoder'
gem 'lcbo',        '1.4.0'
gem 'rdiscount'
gem 'haml-rails'
gem 'exceptional'
gem 'whenever',    require: false
gem 'colored',     require: false
gem 'zippy',       require: false
gem 'aws-s3',      require: false
gem 'unicorn',     require: false

group :assets do
  gem 'jquery-rails'
  gem 'sass-rails'
  gem 'therubyracer'
  gem 'uglifier'
end

group :development do
  gem 'hooves',            require: 'hooves/default'
  gem 'awesome_print'
  gem 'capistrano',        require: false
  gem 'capistrano-ext',    require: false
  gem 'capistrano_colors', require: false
  gem 'rvm-capistrano',    require: false
end

group :test, :development do
  gem 'rspec-rails'
  gem 'capybara',    require: false
  gem 'fabrication', require: false
end

group :test do
  gem 'database_cleaner'
end
