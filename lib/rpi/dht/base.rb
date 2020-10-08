module RPi
  module Dht
    class InvalidByteSetError < StandardError; end
    class InvalidByteError < StandardError; end
    class ParityError < StandardError; end

    class Base
      CLEAR_SIGNALS = 500 / 1000.to_f
      START_SIGNAL = 1 / 1000.to_f
      VALID_BYTE_SIZE = 5 # humidity_high, humidity_low, temp_high, temp_low, parity
      BITS_IN_BYTE = 8
      HUMIDITY_PRECISION = 10.to_f
      TEMPERATURE_PRECISION = 10.to_f
      ENOUGH_TO_CAPTURE_COUNT = 1000 # collecting high/low this many times should be enough (rough estimate...)

      class << self
        def read!(pin)
          dht = new(pin)
          dht.send_start_signal
          dht.collect_response_bits
          dht.convert
        end

        def read(pin, tries: 50)
          tries.to_i.times do
            value = ignore_exception { read!(pin) }
            return value if value.is_a?(Hash)
            sleep 0.1
          end

          nil
        end

        private

        def ignore_exception
          yield
        rescue => ex
        end
      end

      def initialize(pin)
        @pin = pin
      end

      def send_start_signal
        # https://i.gyazo.com/a3e13113125d56326517fa936c6011fc.png
        # The OUTPUT part
        RPi::GPIO.setup pin, as: :output, initialize: :high
        sleep(CLEAR_SIGNALS)

        RPi::GPIO.set_low pin
        sleep(START_SIGNAL)
      end

      def collect_response_bits
        # https://i.gyazo.com/a3e13113125d56326517fa936c6011fc.png
        # The INPUT part (until the release just below)
        RPi::GPIO.setup pin, as: :input, pull: :up
        @bits = ENOUGH_TO_CAPTURE_COUNT.times.collect { RPi::GPIO.high?(pin) }
        release

        break_into_byte_strings
        check_parity!
      end

      private

      attr_reader :pin, :bits, :byte_strings

      def release
        RPi::GPIO.clean_up pin
      end

      def break_by_high_or_low
        # group trues with trues / falses with falses
        # [
        #   [true, true, true, ...],
        #   [false, false, false, ...],
        #   ...
        # ]
        last_value = :not_yet
        bits.slice_before do |value|
          (last_value != value).tap { |not_same| last_value = value if not_same }
        end.to_a
      end

      def break_into_byte_strings
        # https://i.gyazo.com/a3e13113125d56326517fa936c6011fc.png
        # response signal (ture / false arrays) before data (useless)

        # ture/false array pair
        # data part is 5bytes = 40bits = 40pairs of true and false arrays = 80 arrays
        # [false, false, false, ...]
        # [true, true, true, ...]
        # [false, false, false, ...]
        # [true, true, true, ...]
        # [false, false, false, ...]
        # [true, true, true, ...]
        # ...
        # ...
        # ...

        # end_part (useless), but it's an indicator that 40 pairs before this is the data
        # after data, it ends with short period of falses then eternal trues
        # [false, false, false, ...]
        # [true, true, true, true, true, true, true, true, true, ...]

        # take last 82 elements and make pairs
        pair = 2
        end_part_pair = pair
        *low_high_pairs, end_part =
          break_by_high_or_low.last(VALID_BYTE_SIZE * BITS_IN_BYTE * pair + end_part_pair)
            .each_slice(2).to_a

        # https://i.gyazo.com/baba7ce475e945c732491a6afc9e4b9a.png
        # low_high_pairs = [
        #   ture / false array pair = 1bit
        #   8elements of them = 1byte worth of data
        #   [
        #     [[false, false ...], [true, true ...]],  1
        #     [[false, false ...], [true, true ...]],  2
        #     [[false, false ...], [true, true ...]],  3
        #     [[false, false ...], [true, true ...]],  4
        #     [[false, false ...], [true, true ...]],  5
        #     [[false, false ...], [true, true ...]],  6
        #     [[false, false ...], [true, true ...]],  7
        #     [[false, false ...], [true, true ...]],  8
        #   ]

        #   ...
        #   total of 5 bytes
        # ]

        valid_bytes =
          low_high_pairs.each_slice(8).to_a.select do |pair|
            pair.all? { |x| x.is_a?(Array) }
          end

        unless valid_bytes.size == VALID_BYTE_SIZE
          raise InvalidByteSetError.new(
                  "not valid byte set (#{valid_bytes.size}bytes, should be #{
                    VALID_BYTE_SIZE
                  }bytes)"
                )
        end

        valid_bytes.each do |byte|
          unless byte.size == BITS_IN_BYTE
            raise InvalidByteError.new(
                    "not a byte (#{byte.size}bits, should be #{BITS_IN_BYTE}bits)"
                  )
          end
        end

        # [
        #   [false, false, false, ...],
        #   [false, false, false, ...],
        #   [false, false, false, ...],
        #   ...
        # ]
        all_falses = valid_bytes.collect { |byte| byte.collect(&:first) }.flatten(1)
        average_50us_false_size = all_falses.sum(&:size) / all_falses.size.to_f

        # https://i.gyazo.com/085693e497f9105bc66392d05112e0d3.png
        @byte_strings =
          valid_bytes.collect do |byte|
            byte.collect { |_, trues| average_50us_false_size <= trues.size ? 1 : 0 }.join
          end
      end

      def bytes
        byte_strings.collect { |x| x.to_i(2) }
      end

      def check_parity!
        humidity_high, humidity_low, temp_high, temp_low, parity = bytes
        unless (humidity_high + humidity_low + temp_high + temp_low) == parity
          raise ParityError.new("parity check failed")
        end
      end

      def fahrenheit(celsius)
        (celsius.to_f * 1.8 + 32).round(2)
      end
    end
  end
end
