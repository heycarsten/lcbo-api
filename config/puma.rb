threads_count = ENV.fetch('RAILS_MAX_THREADS') { 32 }
threads threads_count, threads_count

environment ENV.fetch('RAILS_ENV') { 'development' }

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked webserver processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
# workers ENV.fetch('WEB_CONCURRENCY') { 2 }

# on_worker_boot do
#   ActiveRecord::Base.establish_connection
#   $redis.client.reconnect
# end

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
#
preload_app!

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
