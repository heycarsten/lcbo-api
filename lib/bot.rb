module Bot
  def self.define(&block)
    TaskSet.new(&block)
  end
end

require 'bot/task'
require 'bot/task_set'
