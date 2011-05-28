require 'bundler/capistrano'
require 'rvm/capistrano'
require 'whenever/capistrano'

default_run_options[:pty] = true

set :use_sudo,          false
set :environment,       'production'
set :domain,            'lcboapi.com'
set :user,              'lcboapi'
set :runner,            user
set :admin_runner,      runner
set :application,       'lcboapi'
set :repository,        'git@github.com:heycarsten/lcbo-api.git'
set :deploy_to,         '/home/lcboapi/lcboapi.com'
set :deploy_via,        :remote_cache
set :copy_exclude,      ['.git']
set :scm,               :git
set :git_shallow_clone, true
set :scm_verbose,       false
set :whenever_command,  'bundle exec whenever'
set :keep_releases,     10
set :bundle_flags,      '--deployment --binstubs --quiet'

server domain, :db, :app, :web, :primary => true

after 'deploy:update_code', 'db:symlink'
after 'deploy:update_code', 'config:symlink'
after :deploy, 'deploy:cleanup'

namespace :deploy do
  desc 'Run the migrate rake task.'
  task :migrate, :roles => :db do
    run "cd #{latest_release} && bin/rake db:migrate"
  end

  desc 'Start app with Unicorn'
  task :start, :except => { :no_release => true }, :roles => :app do
    run %{
      cd #{current_path} &&
      bin/unicorn -E #{environment} -D -o 127.0.0.1 -c #{current_path}/config/unicorn.rb #{current_path}/config.ru
    }
  end

  desc 'Stop app'
  task :stop, :except => { :no_release => true }, :roles => :app do
    on_rollback { start }
    sudo "kill -QUIT `cat #{shared_path}/pids/unicorn.pid` && exit 0"
  end

  desc 'Gracefully restart app with Unicorn'
  task :restart, :except => { :no_release => true } do
    sudo "kill -HUP `cat #{shared_path}/pids/unicorn.pid` && exit 0"
  end
end

namespace :config do
  desc 'Symlink app configuration'
  task :symlink do
    run "ln -nfs #{shared_path}/tmp #{release_path}/tmp"
    run "ln -nfs #{shared_path}/config/lcboapi.yml #{release_path}/config/lcboapi.yml"
  end
end

namespace :db do
  desc 'Update symlinks on app server.'
  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end
