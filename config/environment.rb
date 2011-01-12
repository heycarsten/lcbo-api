# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
LCBOAPI::Application.initialize!

# Flush caches
LCBOAPI.flush

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    $memcache.reset if forked
  end
end
