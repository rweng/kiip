require 'yaml'

module Kiip
  class Castle
    class Config
      attr_reader :castle, :packages

      def initialize castle
        @castle = castle
        @packages = {}
      end

      # loads configuration from config file
      # @raise [IOError] when file could not be loaded
      def load!
        content = load_config
        package_definitions = content.packages || raise(Kiip::Errors::IllegalStateError, "packages must be defined in #{path}")

        @packages = package_definitions.inject({}) do |result, k|
          package_name, package_def = k

          result[package_name] = Kiip::Package.new(name: package_name, source: package_def['source'], castle: castle)
          result
        end
      end

      def rm package_name
        @packages.delete package_name
      end

      def path
        File.join(castle.path, 'config.yml')
      end

      def exists?
        File.exists? path
      end

      def save!
        File.open(path, 'w') { |f| f.write file_content.to_yaml }
      end

      def file_content
        packages_hash = packages.values.inject({}) do |result, package|
          result[package.name] = {
              source: package.source
          }.stringify_keys

          result
        end

        {
            'packages' => packages_hash
        }
      end

      private
      # @return [Hashie::Mash]
      # @raise [IOError] when file could not be loaded
      def load_config
        begin
          Hashie::Mash.load(path)
        rescue ArgumentError
          raise IOError, "could not load file #{path}"
        end
      end
    end
  end
end