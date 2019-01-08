# Make sure GCoder uses Redis.new, not Redis.connect
module GCoder
  module Storage
    class ModernRedisAdapter < RedisAdapter
      def connect
        require 'redis'
        @rdb      = Redis.new(url: config[:url] || 'redis://127.0.0.1/0')
        @keyspace = "#{config[:keyspace] || 'gcoder'}:"
      end
    end

    register :modern_redis, ModernRedisAdapter
  end
end

GEO = GCoder.connect \
  storage: :modern_redis,
  storage_config: {
    url:     Rails.application.secrets.redis,
    key_ttl: 86400 # 24 hours
  },
  bounds: [[50.09, -94.88], [41.87, -74.16]], # Ontario: The Populated Parts
  region: :ca,
  append: ', Ontario, Canada'
