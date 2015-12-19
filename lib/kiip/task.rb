module Kiip

  # basic task, just does symlinks. More might follow
  class Task < Hashie::Dash
    include Hashie::Extensions::Dash::Coercion

    # task name for defining which ones to run
    property :name, required: true, coerce: String

    # the original
    property :source, required: true, coerce: String

    # the place in the castle
    property :target, required: true, coerce: String

    # actually execute the task
    def exec!
      if File.exists?(source)
        raise 'source and target cant both exist' if File.exists?(target)
        raise "source is a symlink: #{source}" if File.symlink? source

        Command.run "mv #{source} #{target}"
        Command.run "ln -s #{target} #{source}"
      else
        raise "source must exist: #{source}"
      end


    end
  end
end