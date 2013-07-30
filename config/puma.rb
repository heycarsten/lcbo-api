bind 'unix:///var/run/lcboapi.sock'
pidfile '/sites/lcboapi.com/shared/tmp/puma'
state_path '/sites/lcboapi.com/shared/tmp/puma/state'

threads 8,32
workers 3
preload_app!

on_restart do
  RDB.client.disconnect
  DB.disconnect
end

on_worker_boot do
  RDB.client.connect
end
