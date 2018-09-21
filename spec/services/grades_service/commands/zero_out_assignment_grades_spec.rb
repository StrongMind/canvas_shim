describe GradesService::Commands::ZeroOutAssignmentGrades do
  subject {described_class.new(submission)}
  let(:assignment) { double("assignment", grade_student: nil, published?: true) }
  let(:user) {double("user")}
  let(:grader) {double("grader")}
  let(:submission) do
    double(
      "submission",
      assignment: assignment,
      user: user,
      workflow_state: 'unsubmitted',
      score: nil,
      grade: nil,
      due_at: 1.hour.ago,
      grader: nil
    )
  end

  before do
    allow(GradesService::Account).to receive(:account_admin).and_return(grader)
  end

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

      it 'uses the correct grader' do
        expect(assignment).to receive(:grade_student).with(any_args, hash_including(grader: grader))
        subject.call!
      end

      it 'updates the score to 0' do
        expect(assignment).to receive(:grade_student).with(any_args, hash_including(score: 0))
        subject.call!
      end

      it 'logs'
    end

    context 'when submission is submitted' do
      before do
        allow(submission).to receive(:workflow_state).and_return('submitted')
      end

      it 'will not grade' do
        expect(assignment).to_not receive(:grade_student)
        subject.call!
      end
    end

    context 'when submission is graded' do
      before do
        allow(submission).to receive(:workflow_state).and_return('graded')
      end

      it 'will not grade' do
        expect(assignment).to_not receive(:grade_student)
        subject.call!
      end
    end

    context 'when submission has a score' do
      before do
        allow(submission).to receive(:score).and_return(1)
      end

      it 'will not grade' do
        expect(assignment).to_not receive(:grade_student)
        subject.call!
      end
    end

    context 'when submission has a grade' do
      before do
        allow(submission).to receive(:grade).and_return(1)
      end

      it 'will not grade' do
        expect(assignment).to_not receive(:grade_student)
        subject.call!
      end
    end

    context 'when submission is not late' do
      before do
        allow(submission).to receive(:due_at).and_return(1.minute.ago)
      end

      it 'will not grade' do
        expect(assignment).to_not receive(:grade_student)
        subject.call!
      end
    end

    context 'when submission is on an unpublished assignment' do
      before do
        allow(assignment).to receive(:published?).and_return(false)
      end

      it 'will not grade' do
        expect(assignment).to_not receive(:grade_student)
        subject.call!
      end
    end
  end

end
