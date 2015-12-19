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
      if File.exists?(source)
        raise 'source and target cant both exist' if File.exists?(target)
        raise "source is a symlink: #{source}" if File.symlink? source

        move_source_to_target
        create_symlink_from_source_to_target
      else
        raise "source must exist: #{source}"
      end
    end

    # recreates the symlink if it does not exist
    def sync!
      return create_symlink_from_source_to_target if not File.exists? source

      # return if its already the correct link
      return if File.symlink? source and File.readlink(source) == target

      raise 'source does already exist'
    end

    private
    def move_source_to_target
      FileUtils.mv source, target
    end

    def create_symlink_from_source_to_target
      FileUtils.symlink(source, target)
    end
  end
end