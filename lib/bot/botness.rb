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

      def run(starting_job = nil)
        new.run(starting_job)
      end
    end

    def initialize
      @current_job = self.class.jobs[0]
    end

    def dot(char = '.')
      STDOUT.print(char)
      STDOUT.flush
    end

    def next_job
      @current_job = self.class.jobs[self.class.jobs.index(@current_job) + 1]
    end

    def run(starting_job = nil)
      @current_job = starting_job.to_sym if starting_job
      fire :before_all unless starting_job
      while @current_job
        begin
          time = Time.now
          fire :before_each, job_name
          send(job_name.to_sym)
          fire :after_each, job_name, (Time.now - time)
        rescue => error
          fire :failure, job_name, (Time.now - time), error
          raise error
        end
        next_job
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
