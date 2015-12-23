module Kiip
  # a Package is a file or folder that get synced
  class Package < Hashie::Dash
    include Hashie::Extensions::Dash::Coercion

    # Package name for defining which ones to run
    property :name, required: true, coerce: String

    # where is the package normally located, e.g. ~/.ssh
    property :source, required: true, coerce: String

    # castle to which the package belongs. tasks cannot be created without castle being set
    property :castle

    # returns the task associated with this package. right now, we have only symlink tasks.
    # @return [Kiip::Tasks::SymlinkTask]
    # @raise [IllegalStateError] - when castle is not set
    def task
      raise Kiip::Errors::IllegalStateError.new, 'castle must be set to create a task' if castle.nil?

      @task ||= Kiip::Tasks::SymlinkTask.new(name: name, source: source, target: castle.package_path(self))
    end

    def to_h
      {
          name: name,
          source: source
      }
    end
  end
end