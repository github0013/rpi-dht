RSpec.describe RPi::Dht::Dht11 do
  let(:pin) { 4 }

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
