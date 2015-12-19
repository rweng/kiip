require "kiip/version"

require 'thor'
require 'hashie'
require 'command'
require 'highline'

module Kiip
  CONFIG = '~/.kiip.rc.yml'

  autoload :Cli, 'kiip/cli'
  autoload :Syncer, 'kiip/syncer'
  autoload :Config, 'kiip/config'
  autoload :Task, 'kiip/task'
  autoload :Castle, 'kiip/castle'
  autoload :Manager, 'kiip/manager'

  def self.root
    File.expand_path(File.join(__dir__, '..'))
  end
end
