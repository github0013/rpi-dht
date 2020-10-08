module RPi
  module Dht
    class Dht22 < Base
      def convert
        humidity_high, humidity_low, temp_high, temp_low, _ = bytes

        is_negative = 0 < (temp_high & 0b10000000)
        temp_high &= 0b01111111

        humidity = ((humidity_high << 8) + humidity_low) / HUMIDITY_PRECISION
        temperature = ((temp_high << 8) + temp_low) / TEMPERATURE_PRECISION
        temperature *= -1 if is_negative

        {
          humidity: humidity,
          temperature: temperature,
          temperature_f: fahrenheit(temperature)
        }
      end
    end
  end
end
