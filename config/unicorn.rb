wd       = '/home/lcboapi/lcboapi.com'
app_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

listen      "#{wd}/shared/sockets/unicorn.sock"
pid         "#{wd}/shared/pids/unicorn.pid"
stderr_path "#{wd}/shared/log/unicorn.stderr.log"
stdout_path "#{wd}/shared/log/unicorn.stdout.log"

working_directory app_root
worker_processes  4
timeout           10
preload_app       true

before_fork do |server, worker|
  RDB.client.disconnect
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
end

after_fork do |server, worker|
  RDB.client.connect
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
end
