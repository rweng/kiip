module Kiip
  class Cli < Thor

    desc 'sync PATH_TO_CONFIG', 'executes commands defined in the config file'
    def sync(path_to_config_file)
      Syncer.new(path_to_config_file).run
    end
  end
end
