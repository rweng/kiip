module Kiip
  class Config
    attr_reader :tasks

    def initialize config_hash
      raise 'config_hash must be a hash' unless config_hash.is_a? Hash

      @config = config_hash
      create_tasks
    end

    private
    def create_tasks
      @tasks = @config['tasks'].map do |name, definition|
        Kiip::Task.new(
            name: name,
            target: definition['target'] || File.join(@config['target'], name)
        )
      end
    end
  end
end
