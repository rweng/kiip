module Kiip
  class Cli < Thor
    class_option :dry, :type => :boolean, default: false
    class_option :verbose, :type => :boolean, default: false

    desc 'track PACKAGE_NAME PATH', 'tracks the file or folder under PATH with the package name NAME. wrap PATH in quotes to ensure ~ and env variables are kept.'
    def track package_name, file_or_folder
      repository.track(package_name, file_or_folder)
    end

    desc 'sync PACKAGE_NAME', 'recreates the source of the package (via symlink, copy, etc)'
    def sync package_name
      repository.sync!(package_name)
    end

    desc 'list', 'lists all packages'
    def list
      puts repository.print_content
    end

    option :remove_source, default: false, type: :boolean, desc: 'if the source should be removed, defaults to false'
    option :remove_target, default: false, type: :boolean, desc: 'if the source should be removed, defaults to false'
    option :replace_source, default: false, type: :boolean, desc: 'if the source should be replaced with the target, defaults to false'
    desc 'rm NAME', 'removes package with name NAME, see: kiip help rm'
    def rm package_name
      repository.rm package_name
    end

    private
    def repository
      Kiip::Repository.get_instance(dry: options[:dry], verbose: options[:verbose])
    end
  end
end
