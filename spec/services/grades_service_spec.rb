describe GradesService do
  let(:assignment) { double('assignment') }
  let(:instance) { double('command_instance', call!: nil)}
  let(:scope) { double('scope') }

  before do
    allow(GradesService::Commands::ZeroOutAssignmentGrades)
      .to receive(:new).and_return(instance)

    allow(scope).to receive(:in_batches).and_yield([assignment])

    allow(GradesService).to receive(:scope).and_return(scope)
    allow(GradesService::Commands::ZeroOutAssignmentGrades).to receive(:new).and_return(instance)
    allow(SettingsService).to receive(:get_settings).and_return({'zero_out_past_due' => 'on'})
  end

  it 'calls the command' do
    expect(instance).to receive(:call!)
    described_class.zero_out_grades!(seconds_to_sleep: 0)
  end
end
