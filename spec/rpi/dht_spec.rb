RSpec.describe RPi::Dht do
  it "has a version number" do
    expect(RPi::Dht::VERSION).not_to be nil
  end

  it "is a blackhole (Naught null object)" do
    expect(RPi::GPIO).to be_a? Naught
  end

  describe "reads" do
    let(:pin) { 4 }
    subject { RPi::Dht }

    it "should read dht11!" do
      expect(RPi::Dht::Dht11).to receive(:read!).with(pin)
      subject.read_11!(pin)
    end

    it "should read dht11" do
      expect(RPi::Dht::Dht11).to receive(:read).with(pin, tries: 13)
      subject.read_11(pin, tries: 13)
    end

    it "should read dht22!" do
      expect(RPi::Dht::Dht22).to receive(:read!).with(pin)
      subject.read_22!(pin)
    end

    it "should read dht22" do
      expect(RPi::Dht::Dht22).to receive(:read).with(pin, tries: 13)
      subject.read_22(pin, tries: 13)
    end
  end
end
