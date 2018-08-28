describe GradesService do
  subject { described_class }
  let(:command) { GradesService::Commands::ZeroOutAssignmentGrades }
  let!(:assignment) { Assignment.create!(due_at: 2.days.ago, published: true, context: course) }
  let(:course) { Course.create! }


  before do
    ENV['CANVAS_DOMAIN'] = 'localhost'
    allow(SettingsService).to receive(:get_settings).and_return('zero_out_past_due' => 'on')
  end

  describe '#zero_out_grades!' do
    context 'no submissions'  do
      it 'calls the command' do
        expect(command).to receive(:new).with(Assignment.first).and_return(double("command", call!: nil))
        subject.zero_out_grades!(sleep: false)
      end
    end

    context 'with submissions' do
      let!(:submission) { Submission.create(assignment: assignment) }

      it 'calls the command' do
        expect(command).to receive(:new).with(Assignment.first).and_return(double("command", call!: nil))
        subject.zero_out_grades!(sleep: false)
      end
    end
  end
end
