require "pathname"

module Kiip
  class Repository < Hashie::Dash
    autoload :Package, 'kiip/repository/package'
    ID_FILE_NAME = '.kiip_repository'

    def self.get_instance(**options)
      path = ENV['KIIP_REPO'] || raise('KIIP_REPO environment variable not defined')

      options[:path] = path

      return self.new(**options)
    end

    include Hashie::Extensions::Dash::PropertyTranslation
    property :path, required: true, coerce: String
    property :is_dry, default: false
    property :is_verbose, default: false

    def exists?
      id_file_path = File.join(path, ID_FILE_NAME)
      File.exists? id_file_path
    end

    def unlink *package_names
      package_names.each do |name|
        get_package(name).unlink
      end
    end

    def restore *package_names
      package_names.each do |name|
        get_package(name).restore
      end
    end

    def sync! *names
      names = package_names if names.empty?
      names.each { |name| get_package(name).sync! }
    end

    def track package_name, path
      return unless ensure_existance
      package = get_package(package_name)
      package.create! unless package.exists?
      package.track(path)
    end

    # @return [String] multi-line string with content of the repository
    def print_content
      StringIO.open do |result|
        packages.each do |package|
          result.puts package.name + ':'
          package.decoded_content.each { |content| result.puts '  ' + content }
        end

        result.string
      end
    end

    def packages
      package_names.map do |package_name|
        get_package(package_name)
      end
    end

    def create!
      FileUtils.mkdir_p(path)
      FileUtils.touch(File.join(path, ID_FILE_NAME))
    end

    def rm *package_names
      package_names.each do |package_name|
        get_package(package_name).rm
      end
    end

    private
    # asks user to create repository if it doesn't exist
    #
    # @return [boolean] true if repo exists now
    def ensure_existance
      return true if exists?

      if HighLine.new.agree("Repository #{path} does not exist. Want me to create it? (yes/no)")
        create!
      end

      exists?
    end

    def get_package(package_name)
      Package.new(name: package_name, repository: self)
    end

    # @return [String[]]
    def package_names
      Pathname.new(path).children.select(&:directory?).map(&:basename).map(&:to_s)
    end
  end
end