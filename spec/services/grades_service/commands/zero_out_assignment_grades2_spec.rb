describe GradesService::Commands::ZeroOutAssignmentGrades do
  subject {described_class.new(submission)}
  let(:assignment) { double("assignment") }
  let(:user) {double("user")}
  let(:submission) { double("submission", assignment: assignment, user: user, workflow_state: 'unsubmitted', score: nil, grade: nil, due_at: 1.hour.ago) }


  context '#call' do
    context 'when assingment is unsubmitted and late' do
      it 'grades' do
        expect(assignment).to receive(:grade_student)
        subject.call!
      end

      context 'notifications' do
        it 'mutes notifications'
        it 'unmutes notifications'
      end
      it 'uses the correct grader'
      it 'updates the score to 0'

    end

    context 'when assingment is submitted' do
      before do
        allow(submission).to receive(:workflow_state).and_return('submitted')
      end

      it 'will not grade' do
        expect(assignment).to_not receive(:grade_student)
        subject.call!
      end
    end

    context 'when assingment is graded' do
      before do
        allow(submission).to receive(:workflow_state).and_return('graded')
      end

      it 'will not grade' do
        expect(assignment).to_not receive(:grade_student)
        subject.call!
      end
    end

    context 'when assingment has a score' do
      before do
        allow(submission).to receive(:score).and_return(1)
      end

      it 'will not grade' do
        expect(assignment).to_not receive(:grade_student)
        subject.call!
      end
    end

    context 'when assingment has a grade' do
      before do
        allow(submission).to receive(:grade).and_return(1)
      end

      it 'will not grade' do
        expect(assignment).to_not receive(:grade_student)
        subject.call!
      end
    end

    context 'when assingment is not late' do
      before do
        allow(submission).to receive(:due_at).and_return(1.minute.ago)
      end

      it 'will not grade' do
        expect(assignment).to_not receive(:grade_student)
        subject.call!
      end
    end
  end
end
