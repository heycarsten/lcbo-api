bind 'unix:///sites/lcboapi.com/shared/sockets/puma.sock'
environment 'production'

threads 8,32
workers 3
preload_app!

# on_restart do
#   #RDB.client.disconnect
#   #DB.disconnect
# end

on_worker_boot do
  DB.disconnect
  RDB.client.connect
end
