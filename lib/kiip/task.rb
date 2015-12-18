module Kiip
  class Task < Hashie::Dash
    include Hashie::Extensions::Dash::Coercion
    # task name for defining which ones to run
    property :name

    # the original
    property :source, require: true

    # the place in the castle
    property :target, required: true

    # actually execute the definition
    def exec
      if File.exists?(source)
        raise 'source and target cant both exist' if File.exists?(target)

        run "mv #{source} #{target}"
        run "ln -s #{target} #{source}"
      end
    end

    private

    # on bash
    def run cmd
      puts "running: #{cmd}"
      %x(#{cmd})
    end
  end
end