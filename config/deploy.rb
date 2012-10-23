default_run_options[:pty]   = true
ssh_options[:forward_agent] = true

set :rvm_ruby_string,      '1.9.3-p286'
set :rvm_type,             :system
set :repository,           'git@github.com:heycarsten/lcbo-api.git'
set :scm,                  :git
set :use_sudo,             false
set :deploy_via,           :remote_cache
set :copy_exclude,         %w[ .git ]
set :keep_releases,        5
set :user,                 'lcboapi'
set :whenever_environment, defer { environment }
set :rails_env,            defer { environment }
set :bundle_flags,         '--deployment --quiet --binstubs'
set :branch,               ENV['BRANCH'] || 'master'
set :domain,               'lcboapi.com'
set :environment,          'production'
set :application,          'lcboapi'
set :deploy_to,            '/home/lcboapi/lcboapi.com'

server 'lcboapi.com', :web, :app, :db, primary: true

after 'deploy:update_code', 'config:symlink'

namespace :deploy do
  task :start do
    sudo "start #{application}"
  end

  task :stop do
    on_rollback { start }
    sudo "stop #{application}"
  end

  task :restart do
    sudo "restart #{application}"
  end
end

namespace :config do
  desc 'Update symlinks on app server.'
  task :symlink do
    # note: capistrano automatically symlinks shared/log to current/log
    run "ln -nfs #{shared_path}/tmp #{release_path}/tmp"
    run "ln -nfs #{shared_path}/sockets #{release_path}/tmp/sockets"
    run "ln -nfs #{shared_path}/config/*.yml #{release_path}/config/"
  end
end
