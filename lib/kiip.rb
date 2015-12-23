require "kiip/version"

require 'thor'
require 'hashie'
require 'highline'
require 'active_support/core_ext/hash/keys'

module Kiip
  autoload :Cli, 'kiip/cli'
  autoload :Syncer, 'kiip/syncer'
  autoload :Repository, 'kiip/repository'
  autoload :Errors, 'kiip/errors'

  module Tasks
    autoload :SymlinkTask, 'kiip/tasks/symlink_task'
  end

  def self.root
    File.expand_path(File.join(__dir__, '..'))
  end
end
