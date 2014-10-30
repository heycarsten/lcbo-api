$redis = Redis.new(url: Rails.application.secrets.redis, thread_safe: true)
$redis.ping
