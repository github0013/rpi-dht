RSpec.describe RPi::Dht::Dht11 do
  let(:pin) { 4 }

  describe "class" do
    subject { RPi::Dht::Dht11 }
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

  describe "instance" do
    subject { RPi::Dht::Dht11.new pin }
    before { allow(subject).to receive(:bytes).and_return bytes }
    describe "convert" do
      # humidity      49
      # temperature   26
      let(:bytes) { [0b00110001, 0b00000000, 0b00011010, 0b00000000, 0b00000000] }

      context "has good bytes" do
        it "should return humidity and temperature" do
          expect(subject.convert).to eq(
            { humidity: 49, temperature: 26, temperature_f: 78.80 }
          )
        end
      end
    end
  end
end
