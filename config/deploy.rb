default_run_options[:pty] = true

set :user,              'lcboapi'
set :application,       'lcbo-api'
set :repository,        'git@github.com/heycarsten/lcbo-api.git'
set :deploy_to,         '/home/lcboapi/lcboapi.com'
set :deploy_via,        :remote_cache
set :scm,               :git
set :git_shallow_clone, true
set :scm_verbose,       false
set :use_sudo,          false

server '69.164.217.92', :app, :web, :db, :primary => true

after 'deploy:symlink', 'deploy:update_crontab'

namespace :deploy do
  task :start do; end
  task :stop do; end

  desc 'Restart the application'
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc 'Update the crontab file'
  task :update_crontab, :roles => :db do
    run "cd #{release_path} && bundle exec whenever --update-crontab #{application}"
  end
end

        require 'config/boot'
        require 'hoptoad_notifier/capistrano'
