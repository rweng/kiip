require "pathname"

module Kiip
  class Repository < Hashie::Dash
    autoload :Package, 'kiip/repository/package'
    ID_FILE_NAME = '.kiip_repository'

    def self.get_instance(dry:)
      path = ENV['KIIP_REPO'] || raise('KIIP_REPO environment variable not defined')
      return self.new(path: path, dry: dry)
    end

    include Hashie::Extensions::Dash::PropertyTranslation
    property :path, required: true, coerce: String
    property :dry, transform_with: -> (val) { val.to_s == 'true' }

    def exists?
      id_file_path = File.join(path, ID_FILE_NAME)
      File.exists? id_file_path
    end

    def sync! *names
      names = package_names if names.empty?
      names.each { |name| get_package(name).sync! }
    end

    def track package_name, path
      package = get_package(package_name)
      package.create! unless package.exists?
      package.track(path)
    end

    # @return [String] multi-line string with content of the repository
    def print_content
      StringIO.open do |result|
        packages.each do |package|
          result.puts package.name + ':'
          package.content.each { |content| result.puts '  ' + content.gsub(':', '/') }
        end

        result.string
      end
    end

    def packages
      package_names.map do |package_name|
        get_package(package_name)
      end
    end

    private
    def get_package(package_name)
      Package.new(name: package_name, repository: self)
    end

    # @return [String[]]
    def package_names
      Pathname.new(path).children.select(&:directory?).map(&:basename).map(&:to_s)
    end
  end
end