listen 3000
worker_processes 4

user 'lcboapi'

timeout 25

working_directory '/home/lcboapi/lcboapi.com/current'
shared_dir      = '/home/lcboapi/lcboapi.com/shared'

pid         shared_dir + '/pids/unicorn.pid'
stderr_path shared_dir + '/log/unicorn.stderr.log'
stdout_path shared_dir + '/log/unicorn.stdout.log'

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
  old_pid = (shared_dir + '/pids/unicorn.pid.oldbin')
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill('QUIT', File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end
