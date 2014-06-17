module RedisAbuse
  class List
    def initialize(obj, name, cast_type)
      @key       = "#{obj.rdb_keyspace}:#{name}"
      @cast_type = cast_type
    end

    def slice(start = 0, finish = -1)
      $redis.lrange(@key, start, finish).map { |value| cast(value) }
    end
    alias :[] :slice

    def all
      self[0, -1]
    end

    def each
      while (value = pop)
        yield value
      end
    end

    def clear!
      $redis.del(@key)
    end

    def delete(value)
      $redis.lrem(@key, 0, value)
    end

    def push(value)
      $redis.rpush(@key, value)
    end
    alias :<< :push

    def pop
      cast $redis.rpop(@key)
    end

    def concat(array)
      array.values.each { |v| self << v }
    end

    def length
      $redis.llen(@key)
    end

    def cast(value)
      case @cast_type
      when :string
        value.to_s
      when :integer
        value.to_i
      when :float
        value.to_f
      else
        value
      end
    end
  end

  module Model
    extend ActiveSupport::Concern

    included do
      after_destroy :rdb_flush!
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
      $redis.keys("#{rdb_keyspace}*").each do |key|
        $redis.del(key)
      end
    end
  end
end
