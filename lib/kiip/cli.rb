module Kiip
  class Cli < Thor
    desc 'init', 'creates a sample ~/.kiip.rc.yml'
    def init
      Kiip::Config.create_rc
    end

    desc 'track NAME PATH', 'tracks the file or folder under PATH with the name NAME'
    def track name, file_or_folder
      Kiip::Castle.get_instance.track(name, file_or_folder)
    end
  end
end
