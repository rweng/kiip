module Kiip
  class Castle
    autoload :Config, 'kiip/castle/config'

    attr_reader :path, :config

    def self.get_instance
      path = ENV['KIIP_CASTLE'] || raise('KIIP_CASTLE environment variable not defined')
      return self.new(path)
    end

    def initialize castle_path
      @path = castle_path
      @config = Kiip::Castle::Config.new(self)
      @config.load! if @config.exists?
    end

    # lists all tasks
    #
    # @return [Array<String>]
    def list
      config.tasks.map do |task_name, task|
        "#{task.name}: #{task.source} -> #{task.target}"
      end
    end

    # remove a task from the castle
    def rm(task_name, remove_source: false, replace_source: false, remove_target: false)
      config.rm task_name
      config.save!

      task =get_task(task_name)
      raise ArgumentError.new("task #{task_name} not found") unless task

      if remove_source or remove_source
        File.rm task.source
      end

      if replace_source
        if remove_target
          FileUtils.mv task.target, task.source
        else
          FileUtils.cp_r task.target, task.source
        end
      end

      if remove_target and not remove_source
        File.rm task.target
      end
    end

    def get_task name
      config.tasks[name]
    end

    # track a folder or file under the given task name
    def track name, path
      return unless ensure_existance

      task = Kiip::Task.new(
                         name: name,
                         source: path,
                         target: File.join(home_path, name)
      )

      config.tasks[task.name] = task
      config.save!

      run name
    end

    # executes a specific task
    def run name
      task = config.tasks[name.to_s] || raise("task #{name} does not exist")
      task.exec!
    end

    # returns true if castle exists, false if not
    def ensure_existance
      return true if exists?

      cli = HighLine.new
      result = cli.ask "Castle #{path} does not exist. Do you want to create it? (y/n)"

      create! if result == 'y'
      return exists?
    end

    def create!
      FileUtils.mkdir_p home_path
      config.save!
    end

    def exists?
      Dir.exists?(home_path) and config.exists?
    end

    def home_path
      File.join(path, 'home')
    end

    def path_for task_name
      File.join(home_path, task_name)
    end
  end
end