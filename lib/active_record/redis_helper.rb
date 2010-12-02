module ActiveRecord
  module RedisHelper

    def self.included(host)
      host.extend(ClassMethods)
      host.after_destroy(:rdb_flush!)
    end

    class List
      def initialize(obj, name, cast)
        @key = "#{obj.rdb_keyspace}:#{name}"
        @cast_type = cast
      end

      def [](start = 0, finish = -1)
        RDB.lrange(@key, start, finish).map { |value| cast(value) }
      end

      def all
        self[0, -1]
      end

      def clear!
        RDB.del(@key)
      end

      def delete(value)
        RDB.lrem(@key, 0, value)
      end

      def <<(value)
        RDB.rpush(@key, value)
      end

      def pop
        cast RDB.rpop(@key)
      end

      def length
        RDB.llen(@key)
      end

      def cast(value)
        case @cast_type
        when String
          value.to_s
        when Integer
          value.to_i
        when Float
          value.to_f
        else
          value
        end
      end
    end

    module ClassMethods
      def list(name, type = String)
        define_method(name) do
          List.new(self, name, type)
        end
      end
    end

    def rdb_keyspace
      "#{self.class.to_s}:#{id}"
    end

    def rdb_flush!
      RDB.del(*RDB.keys("#{rdb_keyspace}*"))
    end

  end
end
