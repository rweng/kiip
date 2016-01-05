require "base64"

module Kiip
  class Package < Hashie::Dash
    class << self
      def encode path
        Base64.encode64 path
      end

      def decode path
        Base64.decode64 path
      end
    end

    include Hashie::Extensions::Dash::Coercion
    property :name, required: true, coerce: String
    property :repository, required: true

    def entries
      content.map do |encoded_original_path|
        Entry.new(
            source: self.class.decode(encoded_original_path),
            target: File.join(path, encoded_original_path),
            package: self
        )
      end
    end

    def restore
      entries.each &:restore
    end

    # removes the links to the package content
    def unlink
      entries.each &:unlink
    end

    def track(tracking_path)
      raise "path does not exist: #{tracking_path}" unless File.exists?(File.expand_path tracking_path)

      tracking_path = tracking_path.gsub %r{^#{File.expand_path('~')}}, '~'

      # escape /
      escaped_tracking_path = self.class.encode tracking_path

      return if repository.is_dry

      task = Tasks::SymlinkTask.new(name: 'task-name', source: tracking_path, target: File.join(path, escaped_tracking_path), is_verbose: repository.is_verbose, is_dry: repository.is_dry)
      task.exec!
    end

    def sync!
      content.each do |subpath|
        source = self.class.decode subpath
        task = Tasks::SymlinkTask.new(name: 'task-name', source: source, target: File.join(path, subpath), is_verbose: repository.is_verbose, is_dry: repository.is_dry)
        task.exec!
      end
    end

    def decoded_content
      content.map { |s| self.class.decode s }
    end

    # creates the package or raises an error
    def create!
      Dir.mkdir(path)
    end

    def rm
      FileUtils.rm_r(path, verbose: repository.is_verbose, noop: repository.is_dry)
    end

    # @return [boolean]
    def exists?
      File.directory?(path)
    end

    def path
      File.join(repository.path, name)
    end

    # @return [String[]] array of package content files/folders
    def content
      Pathname.new(path).children.map(&:basename).map(&:to_s)
    end
  end
end