default_run_options[:pty]   = true
ssh_options[:forward_agent] = true

set :rvm_ruby_string, '2.0.0'
set :rvm_type,        :user
set :repository,      'git@github.com:heycarsten/lcbo-api.git'
set :scm,             :git
set :use_sudo,        false
set :deploy_via,      :remote_cache
set :copy_exclude,    %w[ .git ]
set :keep_releases,   5
set :user,            'deploy'
set :rails_env,       'production'
set :bundle_flags,    '--deployment --quiet --binstubs'

set :branch,      (ENV['BRANCH'] || 'deployed')
set :domain,      'lcboapi.com'
set :environment, 'production'
set :application, 'lcboapi'
set :deploy_to,   '/sites/lcboapi.com'

server '66.228.45.234', :web, :app, :db, primary: true

after 'deploy:update_code', 'config:symlink'

namespace :deploy do
  task :start do
    run "sudo start puma app=#{current_path}"
  end

  task :stop do
    on_rollback { start }
    run "sudo stop puma app=#{current_path}"
  end

  task :restart do
    run "sudo restart puma app=#{current_path}"
  end
end

namespace :config do
  desc 'Update symlinks on app server.'
  task :symlink do
    # note: capistrano automatically symlinks shared/log to current/log
    run "ln -nfs #{shared_path}/tmp #{release_path}/"
    run "ln -nfs #{shared_path}/config/*.yml #{release_path}/config/"
  end
end
