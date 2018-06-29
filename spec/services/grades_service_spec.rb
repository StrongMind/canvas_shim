describe GradesService do
  let(:assignment) { double('assignment') }
  let(:instance) { double('assignment_instance', call!: nil)}
  before do
    allow(GradesService::Commands::ZeroOutAssignmentGrades).to receive(:new).and_return(instance)
    allow(Assignment).to receive(:all).and_return([assignment])
    allow(GradesService::Commands::ZeroOutAssignmentGrades).to receive(:new).and_return(instance)
  end
  it 'calls the command' do
    expect(instance).to receive(:call!)
    described_class.zero_out_grades!
  end
end
