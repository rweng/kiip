module Kiip
  class Cli < Thor
    desc 'track NAME PATH', 'tracks the file or folder under PATH with the package name NAME'
    def track name, file_or_folder
      Kiip::Castle.get_instance.track(name, file_or_folder)
    end

    desc 'sync NAME', 'recreates the source of the package (via symlink, copy, etc)'
    def sync name
      Kiip::Castle.get_instance.sync!(name)
    end

    desc 'list', 'lists all packages'
    def list
      Kiip::Castle.get_instance.list.each {|line| puts line}
    end

    option :remove_source, default: false, type: :boolean, desc: 'if the source should be removed, defaults to false'
    option :remove_target, default: false, type: :boolean, desc: 'if the source should be removed, defaults to false'
    option :replace_source, default: false, type: :boolean, desc: 'if the source should be replaced with the target, defaults to false'
    desc 'rm NAME', 'removes package with name NAME, see: kiip help rm'
    def rm package_name
      Kiip::Castle.get_instance.rm package_name, **(options.to_h.symbolize_keys)
    end
  end
end
