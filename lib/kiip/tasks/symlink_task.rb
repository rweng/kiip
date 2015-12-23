module Kiip::Tasks

  # basic task, just does symlinks. More might follow
  class SymlinkTask < Hashie::Dash
    include Hashie::Extensions::Dash::PropertyTranslation

    # task name for defining which ones to run
    property :name, required: true, coerce: String

    # the original, removes ending /
    # we must call expand_path to ensure FileUtils.ln_s, File.exists? etc work correctly
    property :source, required: true, transform_with: ->(val) { File.expand_path val.to_s.gsub(/\/$/, '') }

    # the place in the castle
    property :target, required: true, transform_with: ->(val) { File.expand_path val.to_s }

    property :is_verbose, default: false

    property :is_dry, default: false

    # actually execute the task
    def exec!
      return initialize! unless File.exists? target

      return create_symlink_from_source_to_target unless File.exists? source

      return if File.symlink? source and File.readlink(source) == target

      if cli.agree "#{source} already exists. Replace with symlink?"
        remove_source
        create_symlink_from_source_to_target
      end
    end

    def restore
      remove_source
      copy_target_to_source
    end

    private
    def cli
      HighLine.new
    end

    def initialize!
      raise "source must exist to initalize: #{source}" unless File.exists? source
      raise "source must not be a symlink: #{source}" if File.symlink? source

      move_source_to_target
      create_symlink_from_source_to_target
    end

    def copy_target_to_source
      FileUtils.cp_r(target, source, verbose: is_verbose, noop: is_dry)
    end

    def remove_source
      FileUtils.rm_f(source, verbose: is_verbose, noop: is_dry)
    end

    def move_source_to_target
      FileUtils.mv(source, target, verbose: is_verbose, noop: is_dry)
    end

    def create_symlink_from_source_to_target
      FileUtils.ln_s(target, source, verbose: is_verbose, noop: is_dry)
    end
  end
end