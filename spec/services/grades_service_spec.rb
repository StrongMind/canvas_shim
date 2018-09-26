describe GradesService do
  let(:instance) { double('command_instance', call!: nil)}
  let(:submission) { double('submission') }

  before do
    allow(GradesService::Commands::ZeroOutAssignmentGrades).to receive(:new).and_return(instance)
    allow(SettingsService).to receive(:get_settings).and_return({'zero_out_past_due' => 'on'})
    allow(Submission).to receive(:find_each).and_yield(submission)
    allow(described_class).to receive(:save_audit_log)
  end

  it "calls the command and passes on options" do
    expect(instance).to receive(:call!).with(hash_including(dry_run: true))
    described_class.zero_out_grades!(dry_run: true)
  end

  it 'saves the audit log' do
    expect(described_class).to receive(:save_audit_log)
    described_class.zero_out_grades!
  end
end
