module Kiip
  class Entry < Hashie::Dash
    property :source, required: true, coerce: String
    property :target, required: true, coerce: String
    property :package, required: true

    # restores the entry to it's original place
    def restore
      # if file exists, remove or return
      if File.exist?(expanded_source)
        cli.agree("#{source} exists. Remove it?") ? remove_source : return
      end

      FileUtils.copy_entry(target, expanded_source, **file_options)
    end

    # removes the source. If source is not a link to target, it asks the users.
    def unlink
      if not File.exist?(expanded_source)
        cli.say "#{source} does not exist." if file_options[:verbose]
        return
      end

      if (File.symlink?(expanded_source) and File.readlink(expanded_source) == target) or cli.agree("#{source} is not a symlink to #{target}. Still remove it?")
        FileUtils.remove_entry(expanded_source, **file_options)
      end
    end

    private

    def cli
      @cli || HighLine.new
    end

    def expanded_source
      File.expand_path(source)
    end

    def file_options
      {verbose: package.repository.is_verbose, noop: package.repository.is_dry}
    end

    # asks the user if source should be removed and removes it
    def remove_source
      FileUtils.remove_entry(File.expand_path(source), **file_options)
    end
  end
end