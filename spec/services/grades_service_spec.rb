describe GradesService do
  let(:assignment) { double('assignment') }
  let(:instance) { double('command_instance', call!: nil)}
  before do
    ENV['ZERO_OUT_PASTDUE_ASSIGNMENTS'] = 'true'
    allow(GradesService::Commands::ZeroOutAssignmentGrades)
      .to receive(:new).and_return(instance)

    allow(GradesService::Commands::ZeroOutAssignmentGrades).to receive(:new).and_return(instance)
  end

  it 'calls the command' do
    expect(instance).to receive(:call!)
    described_class.zero_out_grades!
  end
end
