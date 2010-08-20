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

    def initialize
      @current_job = self.class.jobs[0]
    end

    def dot(char = '.')
      STDOUT.print(char)
      STDOUT.flush
    end

    def run
      current_job = @starting_job.present? ? @starting_job : @current_job
      fire :before_all if @starting_job.blank?
      while current_job
        begin
          time = Time.now
          fire :before_each, current_job
          send(current_job.to_sym)
          fire :after_each, current_job, (Time.now - time)
        rescue => error
          fire :failure, current_job, (Time.now - time), error
          raise error
        end
        current_job = self.class.jobs[self.class.jobs.index(current_job) + 1]
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
