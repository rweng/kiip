module Kiip
  class Manager


    def initialize(kiiprc)
      @kiiprc = Hashie::Mash.new(kiiprc)
    end

    def track name, path
      castle = castle_for(name)
      castle.track(name, path)
    end

    def castles
      @kiiprc.castles
    end
  end
end