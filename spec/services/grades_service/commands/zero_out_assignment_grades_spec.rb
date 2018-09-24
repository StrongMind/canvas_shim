describe GradesService::Commands::ZeroOutAssignmentGrades do
  subject {described_class.new(submission)}
  let(:assignment) { double("assignment", grade_student: nil, published?: true) }
  let(:user) {double("user")}
  let(:grader) {double("grader")}
  let(:submission) do
    double(
      "submission",
      id: 1,
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
    it 'uses the correct grader' do
      expect(assignment).to receive(:grade_student).with(any_args, hash_including(grader: grader))
      subject.call!
    end

    it 'updates the score to 0' do
      expect(assignment).to receive(:grade_student).with(any_args, hash_including(score: 0))
      subject.call!
    end

    it 'logs'

    context 'notifications' do
      it 'mutes notifications'
      it 'unmutes notifications'
    end

    context 'will not grade' do
      after do
        expect(assignment).to_not receive(:grade_student)
        subject.call!
      end

      it 'when submission is submitted' do
        allow(submission).to receive(:workflow_state).and_return('submitted')
      end

      it 'when submission is graded' do
        allow(submission).to receive(:workflow_state).and_return('graded')
      end

      it 'when submission has a score' do
        allow(submission).to receive(:score).and_return(1)
      end

      it 'when submission is not late' do
        allow(submission).to receive(:grade).and_return(1)
      end

      it 'when submission is on an unpublished assignment' do
        allow(assignment).to receive(:published?).and_return(false)
      end
    end

    context 'when in dry run mode' do
      let(:file) { double(:file, write: nil, close: nil) }

      before do
        allow(File).to receive(:open).and_return(file)
      end

      after do
        subject.call!(dry_run: true)
      end

      it 'will append the file' do
        expect(File).to receive(:open).with('dry_run.log', 'a')
      end

      it 'will not run the command' do
        expect(assignment).to_not receive(:grade_student).with(any_args, hash_including(score: 0))
      end

      it 'will log execution plan' do
        expect(file).to receive(:write).with("Changing submission 1 from nil to 0\n")
      end
    end
  end
end
