module Kiip
  # a Package is a file or folder that get synced
  class Package < Hashie::Dash
    include Hashie::Extensions::Dash::Coercion

    # Package name for defining which ones to run
    property :name, required: true, coerce: String

    # where is the package normally located, e.g. ~/.ssh
    property :source, required: true, coerce: String

    property :castle

    def task
      raise 'castle must be set to create a task' if castle.nil?

      @task ||= Kiip::Task.new(name: name, source: source, target: castle.package_path(self))
    end
  end
end