module Kiip
  class Cli < Thor
    desc 'init', 'creates a sample ~/.kiip.rc.yml'
    def init
      Kiip::Config.create_rc
    end
  end
end
