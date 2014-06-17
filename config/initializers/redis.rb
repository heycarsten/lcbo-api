$redis = Redis.new(thread_safe: true)
$redis.ping
