describe GradesService do
  subject { described_class }

  describe '#zero_out_grades!' do
    let(:command_class) { GradesService::Commands::ZeroOutAssignmentGrades }
    let(:command) { double("command", call!: nil) }
    let(:course) { Course.create! }
    let!(:assignment) do
      Assignment.create!(due_at: 2.days.ago, published: true, context: course)
    end

    before do
      ENV['CANVAS_DOMAIN'] = 'localhost'
      allow(SettingsService).to receive(:get_settings).and_return('zero_out_past_due' => 'on')
      allow(command_class).to receive(:new).with(assignment).and_return(command)
    end

    context 'no submissions'  do
      let!(:assignment) { Assignment.create!(due_at: 2.days.ago, published: true, context: course) }

      it 'calls the command' do
        expect(command_class).to receive(:new).with(assignment)
        subject.zero_out_grades!(seconds_to_sleep: 0)
      end

      it 'no submissions were created' do
        expect(assignment.submissions.count).to eq 0
        subject.zero_out_grades!(seconds_to_sleep: 0)
      end
    end

    context 'setting is not on' do
      before do
        allow(SettingsService).to receive(:get_settings).and_return('zero_out_past_due' => 'off')
      end

      it 'does not call the command' do
        expect(command_class).to_not receive(:new)
        subject.zero_out_grades!(seconds_to_sleep: 0)
      end
    end

    context 'submission with no score' do
      let!(:submission) { Submission.create(assignment: assignment) }

      it 'calls the command' do
        expect(command_class).to receive(:new).with(Assignment.first)
        subject.zero_out_grades!(seconds_to_sleep: 0)
      end
    end

    context 'submissions with scores' do
      let!(:submission) { Submission.create(assignment: assignment, score: 2) }
      it 'does not call the command' do
        expect(command_class).to_not receive(:new)
        subject.zero_out_grades!(seconds_to_sleep: 0)
      end
    end

    context 'submission with score' do
      let!(:submission) { Submission.create(assignment: assignment, score: 1) }

      it 'does not call the command' do
        expect(command_class).to_not receive(:new)
        subject.zero_out_grades!(seconds_to_sleep: 0)
      end
    end

    context 'no due date' do
      let!(:assignment) { Assignment.create!(due_at: nil, published: true, context: course) }
      it 'does not call the command' do
        expect(command_class).to_not receive(:new)
        subject.zero_out_grades!(seconds_to_sleep: 0)
      end
    end

    context 'recent due date' do
      let!(:assignment) { Assignment.create!(due_at: 10.minutes.ago, published: true, context: course) }
      it 'does not call the command' do
        expect(command_class).to_not receive(:new)
        subject.zero_out_grades!(seconds_to_sleep: 0)
      end
    end
  end
end
