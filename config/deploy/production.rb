server '198.74.57.157',  user: 'deploy', roles: [:web]
server '97.107.138.218', user: 'deploy', roles: [:worker, :db]

set :deploy_to, '/sites/lcboapi.com'
set :branch,    ENV['branch'] || 'deployed'
set :rails_env, 'production'

desc 'Add tag for release'
after 'deploy:cleanup', :tag_latest_release do
  on roles(:web), limit: 1 do
    system %{
      git fetch origin --tags &&
      git tag deployed/production/`date +%Y%m%d%H%M%S` &&
      git push origin --tags
    }
  end
end
