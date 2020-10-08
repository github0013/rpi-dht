def rpi?
  `cat /proc/cpuinfo`.include?("Raspberry Pi")
end

if rpi?
  require "rpi_gpio"
  RPi::GPIO.set_numbering :bcm
else
  require "naught"
end

module RPi
  GPIO = Naught.build(&:black_hole).new unless rpi?
end
