conf = {
  production: {
    domain: 'lcboapi.com',
    workers: 4,
    threads: [8, 32]
  },

  staging: {
    domain: 'staging.lcboapi.com',
    workers: 1,
    threads: [1, 10]
  }
}[env]

environment env.to_s
bind        "unix:///sites/#{conf[:domain]}/shared/sockets/puma.sock"
threads     *conf[:threads]
workers     conf[:workers]

preload_app!

on_worker_boot do
  DB.disconnect
  RDB.client.connect
end
