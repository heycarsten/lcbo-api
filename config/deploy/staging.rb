server '66.175.208.251', user: 'deploy', roles: [:web]

set :deploy_to, '/sites/staging.lcboapi.com'
set :branch,    ENV['branch'] || 'staging'
set :rails_env, 'staging'
set :app_slug,  'staging-lcboapi-com'
