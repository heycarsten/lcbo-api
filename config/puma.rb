environment 'production'
bind 'unix:///sites/lcboapi.com/shared/sockets/puma.sock'
threads 8, 32
workers 4

preload_app!

on_worker_boot do
  DB.disconnect
  RDB.client.reconnect
end
