threads 16,32
workers 2

preload_app!

on_worker_boot do
  ActiveRecord::Base.establish_connection
  $redis.client.reconnect
end
