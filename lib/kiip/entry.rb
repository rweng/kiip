module Kiip
  class Entry < Hashie::Dash
    property :source, required: true, coerce: String
    property :target, required: true, coerce: String
    property :package, required: true

    def restore
      # if file exists, remove or return
      if File.exist?(File.expand_path(source))
        cli.agree("#{source} exists. Remove it?") ? remove_source : return
      end

      FileUtils.copy_entry(File.expand_path(target), File.expand_path(source), **file_options)
    end

    private

    def cli
      @cli || HighLine.new
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