module Sequel
  module Plugins
    module Redis

      class List
        def initialize(obj, name, cast)
          @rdb = obj.class.rdb
          @key = "#{obj.rdb_keyspace}:#{name}"
          @cast_type = cast
        end

        def [](start = 0, finish = -1)
          @rdb.lrange(@key, start, finish).map { |value| cast(value) }
        end

        def all
          self[0, -1]
        end

        def clear!
          @rdb.del(@key)
        end

        def delete(value)
          @rdb.lrem(@key, 0, value)
        end

        def <<(value)
          @rdb.rpush(@key, value)
        end

        def pop
          cast @rdb.rpop(@key)
        end

        def length
          @rdb.llen(@key)
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

      def self.configure(model, opts = {})
        model.instance_eval do
          @rdb = (opts[:redis] || RDB)
        end
      end

      module ClassMethods
        attr_reader :rdb

        def list(name, type = String)
          define_method(name) do
            List.new(self, name, type)
          end
        end
      end

      module InstanceMethods
        def rdb_keyspace
          "#{self.class.to_s}:#{id}"
        end

        def rdb_flush!
          self.class.rdb.del(*self.class.rdb.keys("#{rdb_keyspace}*"))
        end

        def after_destroy
          rdb_flush!
          super
        end
      end

    end
  end
end
