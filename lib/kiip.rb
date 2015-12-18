require "kiip/version"

require 'thor'
require 'hashie'
require 'command'

module Kiip
  autoload :Cli, 'kiip/cli'
  autoload :Syncer, 'kiip/syncer'
  autoload :Config, 'kiip/config'
  autoload :Task, 'kiip/task'

  def self.root
    File.expand_path(File.join(__dir__, '..'))
  end
end
