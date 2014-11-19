server '198.74.57.157',  user: 'deploy', roles: [:web]
server '97.107.138.218', user: 'deploy', roles: [:worker, :db]

set :deploy_to, '/sites/lcboapi.com'
set :branch,    ENV['branch'] || 'deployed'
set :rails_env, 'production'
set :app_slug,  'lcboapi-com'
