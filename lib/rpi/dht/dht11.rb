module RPi
  module Dht
    class Dht11 < Base
      def convert
        humidity_high, _, temp_high, _, _ = bytes

        humidity = humidity_high
        temperature = temp_high

        {
          humidity: humidity,
          temperature: temperature,
          temperature_f: fahrenheit(temperature)
        }
      end
    end
  end
end
