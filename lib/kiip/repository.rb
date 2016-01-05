require "pathname"

module Kiip
  class Repository < Hashie::Dash
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
      ensure_existance!
      package_names.each do |name|
        get_package(name).unlink
      end
    end

    def restore *package_names
      ensure_existance!
      package_names.each do |name|
        get_package(name).restore
      end
    end

    def sync! *names
      ensure_existance!
      names = package_names if names.empty?
      names.each { |name| get_package(name).sync! }
    end

    def track package_name, path
      ensure_existance!
      package = get_package(package_name)
      package.create! unless package.exists?
      package.track(path)
    end

    # @return [String] multi-line string with content of the repository
    def print_content
      ensure_existance!
      StringIO.open do |result|
        packages.each do |package|
          result.puts package.name + ':'
          package.content.each do |content|
            decoded_path_original = Kiip::Package.decode(content)
            decoded_path_expanded = File.expand_path decoded_path_original

            if File.symlink?(decoded_path_expanded)
              status = File.readlink(decoded_path_expanded) == File.join(package.path, content) ? 'linked' : 'symlink'
            elsif File.directory?(decoded_path_expanded)
              status = 'directory'
            elsif File.file? decoded_path_expanded
              status = 'file'
            elsif not File.exist? decoded_path_expanded
              status = 'not existant'
            else
              raise 'unknown status'
            end

            result.puts "  #{decoded_path_original} | #{status}"
          end
        end

        result.string
      end
    end

    def packages
      ensure_existance!
      package_names.map do |package_name|
        get_package(package_name)
      end
    end

    def create!
      FileUtils.mkdir_p(path)
      FileUtils.touch(File.join(path, ID_FILE_NAME))
    end

    def rm *package_names
      ensure_existance!
      package_names.each do |package_name|
        get_package(package_name).rm
      end
    end

    private

    # asks user to create repository if it doesn't exist
    #
    # @raise [IllegalStateError] if the repository doesn't exist
    # @return [boolean] true if repo exists now
    def ensure_existance!
      if not exists? and cli.agree("Repository #{path} does not exist. Want me to create it? (yes/no)")
        create!
      end

      exists?
    end

    def cli
      @cli ||= HighLine.new
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