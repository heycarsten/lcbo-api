# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'lcboapi'
set :repo_url, 'git@github.com:heycarsten/lcbo-api.git'

# Default value for :linked_files is []
set :linked_files, %w[
  config/database.yml
  config/secrets.yml
]

# Default value for linked_dirs is []
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
    on roles(:app), in: :sequence, wait: 5 do
      sudo "service puma restart app=#{current_path}"
    end
  end

  desc 'Stop application'
  task :stop do
    on roles(:app), in: :sequence, wait: 1 do
      sudo "service puma stop app=#{current_path}"
    end
  end

  desc 'Start application'
  task :start do
    on roles(:app), in: :sequence, wait: 1 do
      sudo "service puma start app=#{current_path}"
    end
  end

  after :publishing, :restart
end

desc "Check that we can access everything"
task :check_write_permissions do
  on roles(:all) do |host|
    if test("[ -w #{fetch :deploy_to} ]")
      info "#{fetch :deploy_to} is writable on #{host}"
    else
      error "#{fetch :deploy_to} is not writable on #{host}"
    end
  end
end
