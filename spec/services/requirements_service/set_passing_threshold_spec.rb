describe RequirementsService::Commands::SetPassingThreshold do
  include_context 'stubbed_network'
  
  describe "#call" do
    context "Happy path school" do
      subject { described_class.new(type: 'school', threshold: 70, edited: 'true') }

      it "receives set_threshold" do
        expect(subject).to receive(:set_threshold)
        subject.call
      end

      it "has the correct setting" do
        new_threshold = {
          object: 'school',
          id: 1,
          setting: "score_threshold",
          value: 70
        }

        expect(SettingsService).to receive(:update_settings).with(new_threshold)
        subject.call
      end
    end

    context "Happy path course" do
      subject { described_class.new(type: 'course', threshold: 70, edited: 'true') }

      it "receives set_threshold" do
        expect(subject).to receive(:set_threshold)
        subject.call
      end

      it "has the correct setting" do
        new_threshold = {
          object: 'course',
          id: 1,
          setting: "passing_threshold",
          value: 70
        }

        expect(SettingsService).to receive(:update_settings).with(new_threshold)
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
end