module Kiip::Tasks

  # basic task, just does symlinks. More might follow
  class SymlinkTask < Hashie::Dash
    include Hashie::Extensions::Dash::Coercion

    # task name for defining which ones to run
    property :name, required: true, coerce: String

    # the original
    property :source, required: true, coerce: String

    # the place in the castle
    property :target, required: true, coerce: String

    # actually execute the task
    def exec!
      return initialize! unless File.exists? target

      return create_symlink_from_source_to_target unless File.exists? source

      return if File.symlink? source and File.readlink(source) == target

      raise 'source and target cant both exist' if File.exists?(target)
    end

    private
    def initialize!
      raise "source must exist to initalize: #{source}" unless File.exists? source
      raise "source must not be a symlink: #{source}" if File.symlink? source

      move_source_to_target
      create_symlink_from_source_to_target
    end


    def move_source_to_target
      FileUtils.mv source, target
    end

    def create_symlink_from_source_to_target
      FileUtils.symlink(source, target)
    end
  end
end