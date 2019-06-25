describe RequirementsService::Commands::SetNewThreshold do
  include_context 'stubbed_network'
  
  context "Happy path" do
    subject { described_class.new(type: 'school', threshold: 70, edited: 'true') }

    it "receives set_threshold" do
      expect(subject).to receive(:set_threshold)
      subject.call
    end
  end

  context "Sent a 0" do
    subject { described_class.new(type: 'school', threshold: 0, edited: 'true') }

    it "receives set_threshold" do
      expect(subject).to receive(:set_threshold)
      subject.call
    end
  end

  context "Threshold not edited" do
    subject { described_class.new(type: 'school', threshold: 70, edited: 'false') }

    it "does not receive set_threshold" do
      expect(subject).to_not receive(:set_threshold)
      subject.call
    end
  end

  context "Threshold too high" do
    subject { described_class.new(type: 'school', threshold: 101, edited: 'false') }

    it "does not receive set_threshold" do
      expect(subject).to_not receive(:set_threshold)
      subject.call
    end
  end

  context "Threshold too low" do
    subject { described_class.new(type: 'school', threshold: -1, edited: 'false') }

    it "does not receive set_threshold" do
      expect(subject).to_not receive(:set_threshold)
      subject.call
    end
  end
end