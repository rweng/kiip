module Kiip
  class Cli < Thor

    desc 'sync PATH_TO_CONFIG', 'executes commands defined in the config file'
    def sync(path_to_config_file)
      Syncer.new(path_to_config_file).run
    end

    desc 'init', 'creates a sample ~/.kiip.rc.yml'
    def init
      Kiip::Config.create_rc
    end
  end
end
