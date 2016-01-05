require 'thor'
require 'hashie'
require 'highline'
require 'active_support/core_ext/hash/keys'

require 'kiip/version'

module Kiip
  autoload :Cli, 'kiip/cli'
  autoload :Syncer, 'kiip/syncer'
  autoload :Repository, 'kiip/repository'
  autoload :Errors, 'kiip/errors'
  autoload :Package, 'kiip/package'
  autoload :Entry, 'kiip/entry'

  module Tasks
    autoload :SymlinkTask, 'kiip/tasks/symlink_task'
  end

  def self.root
    File.expand_path(File.join(__dir__, '..'))
  end
end
