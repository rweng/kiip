require "base64"

module Kiip
  class Repository
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


      def track(tracking_path)
        raise "path does not exist: #{tracking_path}" unless File.exists?(File.expand_path tracking_path)

        tracking_path = tracking_path.gsub %r{^#{File.expand_path('~')}}, '~'

        # escape /
        escaped_tracking_path = self.class.encode tracking_path

        puts "running SymlinkTask: #{tracking_path} -> #{File.join(path, escaped_tracking_path)}"

        return if repository.dry

        task = Tasks::SymlinkTask.new(name: 'task-name', source: tracking_path, target: File.join(path, escaped_tracking_path))
        task.exec!
      end

      def sync!
        content.each do |subpath|
          source = self.class.decode subpath
          task = Tasks::SymlinkTask.new(name: 'task-name', source: source, target: File.join(path, subpath))
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
        content.each do |subpath|
          source = self.class.decode subpath
          task = Tasks::SymlinkTask.new(name: 'task-name', source: source, target: File.join(path, subpath))
          task.restore
        end
      end

      # @return [boolean]
      def exists?
        File.directory?(path)
      end

      def path
        File.join(repository.path, name)
      end

      private
      # @return [String[]] array of package content files/folders
      def content
        Pathname.new(path).children.map(&:basename).map(&:to_s)
      end
    end
  end
end