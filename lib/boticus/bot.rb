module Boticus
  class Bot

    STATE_MATRIX = [
      [ :run,    [ :paused, nil           ], :running   ],
      [ :pause,  [ :running               ], :paused    ],
      [ :cancel, [ :running, :paused, nil ], :cancelled ],
      [ :finish, [ :running               ], :finished  ]]

    STATES = STATE_MATRIX.map { |_, _, state| state.to_s }

    attr_reader :model

    def self.state_rule(state)
      unless (row = STATE_MATRIX.find { |row| row[2] == state })
        raise ArgumentError, "Unknown state: #{state.inspect}"
      end
      row
    end

    def self.desc(desc)
      @desc = desc
    end

    def self.tasks
      @tasks ||= []
    end

    def self.tasks_before(name)
      tasks.map { |t| t[0] }.values_at(0..(tasks.index(name.to_sym)))
    end

    def self.task(name, &block)
      tasks << [name.to_sym, @desc]
      define_method(name) { instance_exec(name, &block) }
    end

    def self.run(*args)
      bot = new
      bot.init(*args)
      bot.run
    end

    def run
      if current_task
        log :warn, "Resuming '#{current_task}' task ..."
        perform(current_task)
      else
        if respond_to?(:prepare)
          log :info, 'Preparing ...'
          prepare
          log :info, 'Done preparing.'
        end
        perform
      end
    rescue => error
      log_error(error)
      transition_to :cancelled
      failure(error)
    end

    def perform(task = nil)
      transition_to :running
      self.class.tasks.each do |name, descr|
        next if before_current_task?(name)
        set :task, name
        log :info, "#{descr} ..."
        send(name)
        log :info, "Done #{descr.downcase}."
      end
      transition_to :finished
    end

    def before_current_task?(tsk)
      raise ArgumentError, 'task cannot be nil' unless tsk
      return false unless current_task
      tasks = self.class.tasks.map { |t| t[0] }
      tasks.index(tsk.to_sym) < tasks.index(current_task)
    end

    def set(field, value)
      model.send(:"#{field}=", value)
      model.save
    end

    def get(field)
      model.send(field.to_sym)
    end

    def current_state
      (state = get(:state)) ? state.to_sym : nil
    end

    def current_task
      (task = get(:task)) ? task.to_sym : nil
    end

    def transition_to(state)
      action, can_be, set_to = self.class.state_rule(state)
      if can_be.include?(current_state)
        log :info, "Transition: #{current_state.inspect} => #{state.inspect}"
        set :state, state
      else
        raise StateError, "Can't transition state: #{current_state.inspect} " \
        "=> #{state.inspect}"
      end
    end

    def failure(error)
      raise error
    end

    def log_error(error)
      h = {}
      h[:error_class]     = error.class.to_s
      h[:error_message]   = error.message
      h[:error_backtrace] = error.backtrace.join("\n")
      log(:error, "(#{error.class}) #{error.message}", h)
      puts "---\n#{h[:error_backtrace]}"
    end

    def log(level, msg, payload = {})
      case level
      when :warn
        print "[warning]".bold.yellow
        print " #{msg}\n".yellow
      when :error
        print "[error]".bold.red
        print " #{msg}\n".red
      when :dot
        print '.'
        STDOUT.flush
      else
        print "[#{level}]".bold
        print " #{msg}\n"
      end
    end

  end
end
