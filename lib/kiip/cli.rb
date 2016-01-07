module Kiip
  class Cli < Thor
    class_option :dry, :type => :boolean, default: false, aliases: '-d'
    class_option :verbose, :type => :boolean, default: false, aliases: '-v'

    desc 'track PACKAGE_NAME PATH', 'tracks the file or folder under PATH with the package name NAME. wrap PATH in quotes to ensure ~ and env variables are kept.'
    def track package_name, file_or_folder
      repository.track(package_name, file_or_folder)
    end

    desc 'link PACKAGE_NAME', 'ensures links to the package files exist'
    def link package_name
      repository.sync!(package_name)
    end

    desc 'unlink PACKAGE_NAME', 'removes the links to the package files'
    def unlink package_name
      repository.unlink(package_name)
    end

    desc 'restore PACKAGE_NAME', 'restores the content of the package to the original places'
    def restore package_name
      repository.restore package_name
    end

    desc 'list', 'lists all packages with content'
    def list
      puts repository.print_content
    end

    desc 'rm NAME', 'removes package with name NAME from the repository'
    def rm package_name
      repository.rm package_name
    end

    desc 'version', 'displays kiip version'
    def version
      puts Kiip::VERSION
    end

    private
    def repository
      Kiip::Repository.get_instance(is_dry: options[:dry], is_verbose: options[:verbose])
    end
  end
end
