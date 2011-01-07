# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
LCBOAPI::Application.initialize!

# Flush caches
LCBOAPI.flush
