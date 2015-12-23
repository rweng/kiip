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

    # actually execute the task
    def exec!
      return initialize! unless File.exists? target

      return create_symlink_from_source_to_target unless File.exists? source

      return if File.symlink? source and File.readlink(source) == target

      answer = nil
      loop do
        answer = ask "#{source} already exists. Replace with symlink to #{target}? (y/n)"
        break if %w(y n).include? answer
      end

      if answer == 'y'
        remove_source
        create_symlink_from_source_to_target
      end
    end

    def restore
      remove_source
      copy_target_to_source
    end

    private
    def initialize!
      raise "source must exist to initalize: #{source}" unless File.exists? source
      raise "source must not be a symlink: #{source}" if File.symlink? source

      move_source_to_target
      create_symlink_from_source_to_target
    end

    def copy_target_to_source
      FileUtils.cp_r(target, source, verbose: true)
    end

    def remove_source
      FileUtils.rm_f(source, verbose: true)
    end

    # @return [String] answer
    def ask question
      @cli ||= HighLine.new
      @cli.ask(question)
    end

    def move_source_to_target
      FileUtils.mv(source, target, verbose: true)
    end

    def create_symlink_from_source_to_target
      FileUtils.ln_s(target, source, verbose: true)
    end
  end
end