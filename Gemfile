source :rubygems

gem 'rails',       '3.0.9'
gem 'rake',        '~> 0.8.7', :require => false
gem 'pg'
gem 'yajl-ruby',   :require => 'yajl'
gem 'amatch'
gem 'stringex',    '~> 1.3.0'
gem 'redis'
gem 'dalli'
gem 'rack-cache',  :require => 'rack/cache'
gem 'sequel'
gem 'sequel_pg',   :require => 'sequel'
gem 'gcoder'
gem 'lcbo',        '1.2.3'
gem 'rdiscount'
gem 'haml'
gem 'sass'
gem 'exceptional'
gem 'whenever',    :require => false
gem 'colored',     :require => false
gem 'zippy',       :require => false
gem 'aws-s3',      :require => false

group :production do
  gem 'unicorn'
end

group :development do
  gem 'capistrano'
  gem 'rvm'
  gem 'awesome_print'
end

group :test do
  gem 'fabrication'
end

group :test, :development do
  gem 'rspec-rails'
end
