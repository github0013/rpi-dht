RSpec.describe RPi::Dht::Base do
  describe "errors" do
    it "should have pre-defined standard errors" do
      expect(RPi::Dht::InvalidByteSetError).to be < StandardError
      expect(RPi::Dht::InvalidByteError).to be < StandardError
      expect(RPi::Dht::ParityError).to be < StandardError
    end
  end

  describe "base" do
    let(:pin) { 4 }
    subject { RPi::Dht::Base.new pin }
    before { allow(subject).to receive(:sleep) }

    describe "class" do
      subject { RPi::Dht::Base }
      let(:pin) { 4 }
      let(:instance) { spy :instance }
      let(:ambient_value) { { humidity: 10, temperature: 30, temperature_f: 86 } }

      before { allow(subject).to receive(:new).and_return instance }

      describe "read!" do
        it "should return humidity and temperature" do
          allow(instance).to receive(:convert).and_return(ambient_value)
          expect(subject.read(pin)).to eq(ambient_value)
        end
      end

      describe "read" do
        it "should return humidity and temperature" do
          allow(instance).to receive(:convert).and_return(ambient_value)
          expect(subject.read(pin)).to eq(ambient_value)
        end

        context "when can't read value" do
          it "should not get value" do
            allow(instance).to receive(:convert).and_return(nil)
            expect(subject.read(pin)).to be_nil
          end
        end

        context "when exception occurs" do
          it "should not raise error" do
            allow(instance).to receive(:convert).and_raise(StandardError)
            expect { subject.read(pin) }.not_to raise_error

            expect(subject.read(pin)).to be_nil
          end
        end
      end
    end

    describe "init" do
      it "should hold pin number" do
        expect(subject.send :pin).to eq pin
      end
    end

    describe "send_start_signal" do
      it "should send start signal" do
        allow(RPi::GPIO).to receive(:setup)
        allow(RPi::GPIO).to receive(:set_low)

        subject.send_start_signal

        expect(RPi::GPIO).to have_received(:setup).with(
          pin,
          as: :output, initialize: :high
        )
        expect(RPi::GPIO).to have_received(:set_low).with(pin)
      end
    end

    describe "collect_response_bits" do
      before do
        allow(RPi::GPIO).to receive(:setup)
        allow(RPi::GPIO).to receive(:high?).and_return(false)
        expect(subject).to receive(:release)
      end

      it "should collect bits" do
        expect(subject).to receive(:break_into_byte_strings)
        expect(subject).to receive(:check_parity!)

        subject.collect_response_bits

        expect(subject.send :bits).to match Array
        expect(subject.send(:bits).size).to eq 1000
        expect(subject.send(:bits).uniq.first).to be_falsy

        expect(RPi::GPIO).to have_received(:setup).with(pin, as: :input, pull: :up)
      end
    end

    describe "private" do
      describe "release" do
        it "should release" do
          allow(RPi::GPIO).to receive(:clean_up)
          subject.send :release
          expect(RPi::GPIO).to have_received(:clean_up).with(pin)
        end
      end

      describe "break_by_high_or_low" do
        it "should group trues with trues / falses with falses" do
          allow(subject).to receive(:bits).and_return(
            [false, false, false, true, true, false, false, false, true, true, true, true]
          )

          expect(subject.send :break_by_high_or_low).to eq(
            [
              [false, false, false],
              [true, true],
              [false, false, false],
              [true, true, true, true]
            ]
          )
        end
      end

      describe "break_into_byte_strings" do
        let(:true_initial_response_array) { [true] * 5 }

        let(:false_50us_array) { [false] * 8 }
        let(:false_80us_array) { [false] * 10 }

        let(:true_short_array) { [true] * 5 }
        let(:true_long_array) { [true] * 10 }
        let(:true_80us_array) { [true] * 10 }

        let(:false_array) { [false] * 5 }
        let(:eternal_true_array) { [true] * 100 }

        let(:good_byte_1_array) do
          # 00000001
          [
            false_50us_array,
            true_short_array,
            false_50us_array,
            true_short_array,
            false_50us_array,
            true_short_array,
            false_50us_array,
            true_short_array,
            false_50us_array,
            true_short_array,
            false_50us_array,
            true_short_array,
            false_50us_array,
            true_short_array,
            false_50us_array,
            true_long_array
          ]
        end

        let(:good_byte_0_array) do
          # 00000000
          [
            false_50us_array,
            true_short_array,
            false_50us_array,
            true_short_array,
            false_50us_array,
            true_short_array,
            false_50us_array,
            true_short_array,
            false_50us_array,
            true_short_array,
            false_50us_array,
            true_short_array,
            false_50us_array,
            true_short_array,
            false_50us_array,
            true_short_array
          ]
        end

        let(:bad_byte_array) do
          [
            false_50us_array,
            true_short_array,
            false_50us_array,
            true_short_array,
            false_50us_array,
            true_short_array,
            false_50us_array
          ]
        end

        it "should convert bits to byte strings" do
          parity_array = [
            false_50us_array,
            true_short_array,
            false_50us_array,
            true_short_array,
            false_50us_array,
            true_short_array,
            false_50us_array,
            true_short_array,
            false_50us_array,
            true_short_array,
            false_50us_array,
            true_short_array,
            false_50us_array,
            true_long_array,
            false_50us_array,
            true_short_array
          ]

          allow(subject).to receive(:break_by_high_or_low).and_return(
            [
              false_array,
              true_initial_response_array,
              false_80us_array,
              true_80us_array,
              *good_byte_0_array,
              *good_byte_1_array,
              *good_byte_0_array,
              *good_byte_1_array,
              *parity_array,
              false_array,
              eternal_true_array
            ]
          )

          expect(subject.send :break_into_byte_strings).to eq %w[
               00000000
               00000001
               00000000
               00000001
               00000010
             ]
        end

        context "when valid bytes are not 5 of them" do
          it "should raise error" do
            allow(subject).to receive(:break_by_high_or_low).and_return(
              [
                false_array,
                true_initial_response_array,
                false_80us_array,
                true_80us_array,
                *good_byte_0_array,
                *good_byte_1_array,
                *good_byte_0_array,
                false_array,
                eternal_true_array
              ]
            )

            expect { subject.send :break_into_byte_strings }.to raise_error(
              RPi::Dht::InvalidByteSetError
            )
          end
        end

        context "when bytes are not consist of 8bits" do
          it "should raise error" do
            allow(subject).to receive(:break_by_high_or_low).and_return(
              [
                false_array,
                true_initial_response_array,
                false_80us_array,
                true_80us_array,
                *good_byte_0_array,
                *good_byte_1_array,
                *good_byte_0_array,
                *bad_byte_array,
                *bad_byte_array,
                false_array,
                eternal_true_array
              ]
            )

            expect { subject.send :break_into_byte_strings }.to raise_error(
              RPi::Dht::InvalidByteError
            )
          end
        end
      end

      describe "bytes" do
        it "should convert to integer" do
          allow(subject).to receive(:byte_strings).and_return(%w[00000000 10000000])
          expect(subject.send :bytes).to eq [0, 128]
        end
      end

      describe "check_parity!" do
        it "should check parity" do
          allow(subject).to receive(:bytes).and_return(
            [0b00000000, 0b00000001, 0b00000000, 0b00000001, 0b00000010]
          )

          expect { subject.send :check_parity! }.not_to raise_error
        end

        context "when data corrupted" do
          it "should raise error" do
            allow(subject).to receive(:bytes).and_return(
              [0b00000000, 0b00000001, 0b00000000, 0b00000010, 0b00000010]
            )

            expect { subject.send :check_parity! }.to raise_error(RPi::Dht::ParityError)
          end
        end
      end
    end
  end
end
