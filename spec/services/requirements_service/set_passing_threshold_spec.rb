describe RequirementsService::Commands::SetPassingThreshold do
  include_context 'stubbed_network'
  
  describe "#call" do
    before do
      Course.create
    end

    context "Happy path school" do
      subject { described_class.new(type: 'school', threshold: 70, edited: 'true', assignment_group_name: 'workbook') }

      it "receives set_threshold" do
        expect(subject).to receive(:set_threshold)
        subject.call
      end

      it "has the correct setting" do
        new_threshold = {
          object: 'school',
          id: 1,
          setting: "workbook_passing_threshold",
          value: 70
        }

        expect(SettingsService).to receive(:update_settings).with(new_threshold)
        subject.call
      end
    end

    context "Happy path course" do
      subject { described_class.new(type: 'course', id: Course.first.id, threshold: 70, edited: 'true', assignment_group_name: 'workbook') }

      it "receives set_threshold" do
        expect(subject).to receive(:set_threshold)
        subject.call
      end

      it "has the correct setting" do
        new_threshold = {
          object: 'course',
          id: Course.first.id,
          setting: "workbook_passing_threshold",
          value: 70
        }

        expect(SettingsService).to receive(:update_settings).with(new_threshold)
        subject.call
      end
    end

    context "Sent a 0" do
      subject { described_class.new(type: 'school', threshold: 0, edited: 'true', assignment_group_name: 'workbook') }

      it "does not set_threshold" do
        expect(subject).to_not receive(:set_threshold)
        subject.call
      end

      context "has previous setting" do
        before do
          allow(SettingsService).to receive(:get_settings).and_return({ "workbook_passing_threshold" => 70 })
        end

        it "receives set_threshold" do
          expect(subject).to receive(:set_threshold)
          subject.call
        end
      end
    end

    context "Threshold is the same" do
      subject { described_class.new(type: 'school', threshold: 70, edited: 'true', assignment_group_name: 'workbook') }

      before do
        allow(SettingsService).to receive(:get_settings).and_return({ "workbook_passing_threshold" => 70 })
      end

      it "does not set_threshold" do
        expect(subject).to_not receive(:set_threshold)
        subject.call
      end
    end

    context "Threshold is different" do
      subject { described_class.new(type: 'school', threshold: 75, edited: 'true', assignment_group_name: 'workbook') }

      before do
        allow(SettingsService).to receive(:get_settings).and_return({ "workbook_score_threshold" => 70 })
      end

      it "does not set_threshold" do
        expect(subject).to receive(:set_threshold)
        subject.call
      end
    end

    context "Threshold not edited" do
      subject { described_class.new(type: 'school', threshold: 70, edited: 'false', assignment_group_name: 'workbook') }

      it "does not receive set_threshold" do
        expect(subject).to_not receive(:set_threshold)
        subject.call
      end
    end

    context "Threshold too high" do
      subject { described_class.new(type: 'school', threshold: 101, edited: 'false', assignment_group_name: 'workbook') }

      it "does not receive set_threshold" do
        expect(subject).to_not receive(:set_threshold)
        subject.call
      end
    end

    context "Threshold too low" do
      subject { described_class.new(type: 'school', threshold: -1, edited: 'false', assignment_group_name: 'workbook') }

      it "does not receive set_threshold" do
        expect(subject).to_not receive(:set_threshold)
        subject.call
      end
    end
  end
end