RSpec.describe RPi::Dht::Dht22 do
  let(:pin) { 4 }

  describe "class" do
    subject { RPi::Dht::Dht22 }
    let(:instance) { spy :instance }
    let(:ambient_value) { { humidity: 10, temperature: 30 } }
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

  describe "instance" do
    subject { RPi::Dht::Dht22.new pin }
    before { allow(subject).to receive(:bytes).and_return bytes }
    describe "convert" do
      context "has good bytes" do
        # humidity      527 = 52.7%
        # temperature   345 = 34.5c
        let(:bytes) { [0b00000010, 0b00001111, 0b00000001, 0b01011001, 0b00000000] }

        it "should return humidity and temperature" do
          expect(subject.convert).to eq(
            { humidity: 52.7, temperature: 34.5, temperature_f: 94.1 }
          )
        end
      end

      context "has negative temp" do
        # humidity      527 = 52.7%
        # temperature   345 = 34.5c
        let(:bytes) { [0b00000010, 0b00001111, 0b10000001, 0b01011001, 0b00000000] }

        it "should return negative temperature" do
          expect(subject.convert).to eq(
            { humidity: 52.7, temperature: -34.5, temperature_f: -30.1 }
          )
        end
      end
    end
  end
end
