default_run_options[:pty] = true

set :rvm_type,          :system_wide
set :user,              'lcboapi'
set :application,       'lcbo-api'
set :repository,        'git@github.com:heycarsten/lcbo-api.git'
set :deploy_to,         '/home/lcboapi/lcboapi.com'
set :deploy_via,        :remote_cache
set :scm,               :git
set :git_shallow_clone, true
set :scm_verbose,       false
set :use_sudo,          false
set :whenever_command,  'bundle exec whenever'

server '69.164.217.92', :app, :web, :db, :primary => true

namespace :deploy do
  task :start do; end
  task :stop do; end

  desc 'Restart the application'
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
