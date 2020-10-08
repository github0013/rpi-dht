require "rpi/dht/version"
def debug?
  not `cat /proc/cpuinfo`.include?("Raspberry Pi")
end

if debug?
  require "naught"
else
  require "rpi_gpio"
  RPi::GPIO.set_numbering :bcm
end

require "rpi/dht/base"
require "rpi/dht/dht11"
require "rpi/dht/dht22"

module RPi
  GPIO = Naught.build(&:black_hole).new if debug?

  module Dht
    extend self

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
