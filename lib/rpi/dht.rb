require "rpi/dht/version"
require "rpi/environment"

require "rpi/dht/base"
require "rpi/dht/dht11"
require "rpi/dht/dht22"

module RPi
  module Dht
    extend self

    # https://i.gyazo.com/8de74c9e6a7139e30c2f540715a24dc9.png
    def set_numbering(bcm_or_board = :bcm)
      RPi::GPIO.set_numbering bcm_or_board.to_sym
    end
    set_numbering

    def read_11!(pin)
      Dht11.read!(pin)
    end

    def read_11(pin, tries: 50)
      Dht11.read(pin, tries: tries)
    end

    def read_22!(pin)
      Dht22.read!(pin)
    end

    def read_22(pin, tries: 50)
      Dht22.read(pin, tries: tries)
    end
  end
end
