worker_processes 4
preload_app true

working_directory '/home/lcboapi/unicorn.lcboapi.com/current'
shared_path = '/home/lcboapi/unicorn.lcboapi.com/shared'

listen 3000
timeout 25

pid         shared_path + '/pids/unicorn.pid'
stderr_path shared_path + '/log/unicorn.stderr.log'
stdout_path shared_path + '/log/unicorn.stdout.log'

before_fork do |server, worker|
  # seamless deploy recipe courtesy of
  # http://codelevy.com/2010/02/09/getting-started-with-unicorn
  # i.e. you can run
  # $ PID=log/unicorn.pid; test -s "$PID" && kill -USR2 `cat $PID`
  # from the app root to load the new code and have the workers
  # kill the old master process before forking
  #
  # note: see http://unicorn.bogomips.org/SIGNALS.html for an
  # even safer seamless restart setup (but requires enough RAM
  # to run two unicorn masters and two sets of workers)
  old_pid = (shared_path + '/pids/unicorn.pid.oldbin')
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill('QUIT', File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  ##
  # Unicorn master loads the app then forks off workers - because of the way
  # Unix forking works, we need to make sure we aren't using any of the parent's
  # sockets, e.g. db connection

  $memcache.reset

  # Redis and Memcached would go here but their connections are established
  # on demand, so the master never opens a socket

  worker.user('lcboapi', 'lcboapi') if Process.euid == 0
end
