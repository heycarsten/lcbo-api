lock '3.3.3'

set :application, 'lcboapi'
set :repo_url, 'git@github.com:heycarsten/lcbo-api.git'

set :linked_files, %w[
  config/database.yml
  config/secrets.yml
  config/skylight.yml
]

set :linked_dirs, %w[
  log
  tmp/cache
  tmp/sockets
  tmp/puma
  tmp/pids
]

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:web), in: :sequence, wait: 5 do
      sudo "initctl restart #{fetch :app_slug}-puma"
    end
  end

  desc 'Stop application'
  task :stop do
    on roles(:web), in: :sequence, wait: 1 do
      sudo "initctl stop #{fetch :app_slug}-puma"
    end
  end

  desc 'Start application'
  task :start do
    on roles(:web), in: :sequence, wait: 1 do
      sudo "initctl start #{fetch :app_slug}-puma"
    end
  end

  after :publishing, :restart
end
