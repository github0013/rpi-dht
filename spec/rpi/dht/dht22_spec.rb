RSpec.describe RPi::Dht::Dht22 do
  let(:pin) { 4 }

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
