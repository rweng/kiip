require 'yaml'

module Kiip
  class Syncer
    attr_reader :config

    def initialize(path_to_config_file)
      @config = Kiip::Config.new YAML::load_file(path_to_config_file)
    end

    # runs all definitions or only the ones specified
    def run *definitions
      definitions = self.definitions if definitions.empty?

      definitions.each do |definition|
        run_definition definition
      end
    end

    def run_definition definition

    end

    def definitions
      config.tasks
    end
  end
end

