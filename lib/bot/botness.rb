module Bot
  module Botness

    def self.included(mod)
      mod.instance_variable_set(:@jobs, [])
      mod.instance_variable_set(:@filters, {})
      mod.extend(ClassMethods)
    end

    module ClassMethods
      def filters
        @filters
      end

      def jobs
        @jobs
      end

      def on(event, &block)
        filters[event] = block
      end

      def job(name, &block)
        @jobs << name.to_sym
        define_method(name.to_sym, &block)
      end

      def run
        new.run
      end
    end

    def dot(char = '.')
      STDOUT.print(char)
      STDOUT.flush
    end

    def run
      fire :before_all
      self.class.jobs.each do |job_name|
        begin
          time = Time.now
          fire :before_each, job_name
          send(job_name.to_sym)
          fire :after_each, job_name, (Time.now - time)
        rescue => error
          fire :failure, job_name, (Time.now - time), error
          raise error
        end
      end
      fire :after_all
    end

    protected

    def fire(filter, *args)
      block = self.class.filters[filter.to_sym]
      instance_exec(*args, &block) if block
    end

  end
end
