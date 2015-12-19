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

    # @return [Array<String>]
    def list
      config.tasks.map do |task_name, task|
        "#{task.name}: #{task.source} -> #{task.target}"
      end
    end

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