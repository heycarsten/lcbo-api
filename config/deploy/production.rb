server '69.164.210.217', user: 'deploy', roles: %w[ web app db ]

set :deploy_to, '/sites/lcboapi.com'
set :branch,    ENV['branch'] || 'deployed'
set :rails_env, 'production'

desc 'Add tag for release'
after 'deploy:cleanup', :tag_latest_release do
  on roles(:app), limit: 1 do
    system %{
      git fetch origin --tags &&
      git tag deployed/production/`date +%Y%m%d%H%M%S` &&
      git push origin --tags
    }
  end
end
