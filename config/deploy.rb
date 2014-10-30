lock '3.2.1'

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
      sudo "restart puma app=#{current_path}"
    end
  end

  desc 'Stop application'
  task :stop do
    on roles(:web), in: :sequence, wait: 1 do
      sudo "stop puma app=#{current_path}"
    end
  end

  desc 'Start application'
  task :start do
    on roles(:web), in: :sequence, wait: 1 do
      sudo "start puma app=#{current_path}"
    end
  end

  after :publishing, :restart
end
