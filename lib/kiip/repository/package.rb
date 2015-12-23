module Kiip
  class Repository
    class Package < Hashie::Dash
      include Hashie::Extensions::Dash::Coercion

      property :name, required: true, coerce: String
      property :repository, required: true


      def track(tracking_path)
        raise "path does not exist: #{tracking_path}" unless File.exists?(File.expand_path tracking_path)

        tracking_path = tracking_path.gsub %r{^#{File.expand_path('~')}}, '~'

        # escape /
        escaped_tracking_path = tracking_path.gsub '/', ':'

        puts "running SymlinkTask: #{tracking_path} -> #{File.join(path, escaped_tracking_path)}"

        return if repository.dry

        task = Tasks::SymlinkTask.new(name: 'task-name', source: tracking_path, target: File.join(path, escaped_tracking_path))
        task.exec!
      end

      def sync!
        content.each do |subpath|
          source = subpath.gsub ':', '/'
          task = Tasks::SymlinkTask.new(name: 'task-name', source: source, target: File.join(path, subpath))
          task.exec!
        end
      end

      # @return [String[]] array of package content files/folders
      def content
        Pathname.new(path).children.map(&:basename).map(&:to_s)
      end

      # creates the package or raises an error
      def create!
        Dir.mkdir(path)
      end

      def rm
        content.each do |subpath|
          source = subpath.gsub ':', '/'
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
    end
  end
end