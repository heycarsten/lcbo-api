module Bot
  class TaskSet

    attr_reader :tasks

    def initialize
      @tasks = []
      yield self if block_given?
    end

    def desc(value)
      @desc = value
    end

    def task(slug, &block)
      @tasks << Task.new(slug, @desc, &block)
      @desc = nil
    end

  end
end
