describe GradesService do
  let(:assignment) { double('assignment', id: 1) }
  let(:instance) { double('command_instance', call!: nil)}
  let(:scope) { double('scope', map: [assignment]) }

  before do
    allow(GradesService::Commands::ZeroOutAssignmentGrades)
      .to receive(:new).and_return(instance)

    allow(GradesService).to receive(:scope).and_return(scope)
    allow(GradesService::Commands::ZeroOutAssignmentGrades).to receive(:new).and_return(instance)
    allow(SettingsService).to receive(:get_settings).and_return({'zero_out_past_due' => 'on'})
  end


  context "when there are duplicate ids in the scope" do
    let(:assignments) {[assignment, assignment, assignment2, assignment2]}
    let(:scope) { double('scope', map: assignments) }
    let(:assignment2) { double('assignment', id: 2) }
    it "the command is only called once per id" do
      expect(instance).to receive(:call!).twice
      described_class.zero_out_grades!
    end
  end
end
