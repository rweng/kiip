module Kiip
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

        Command.run "mv #{source} #{target}"
        Command.run "ln -s #{target} #{source}"
      end
    end
  end
end