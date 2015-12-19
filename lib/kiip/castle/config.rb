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
      def load!
        content = YAML::load_file(path)
        @packages = content['packages'].inject({}) do |result, k|
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
    end
  end
end