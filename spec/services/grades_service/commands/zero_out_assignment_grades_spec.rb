describe GradesService::Commands::ZeroOutAssignmentGrades do
  describe '#call' do
    let(:student)  { double('student') }
    let(:context)  { double('context', students: [student]) }
    let(:students) { [student] }

    subject { described_class.new(assignment) }

    context "when the assignment is on time" do
      let(:assignment) { double('assignment', due_date: Time.zone.now)}

      it "do nothing" do
        expect(subject).to_not receive(:students_without_submissions)
        subject.call!
      end
    end

    context 'when the assignment is past due' do
      let(:assignment) do
        double(
          'past due assignment, with student submission',
          due_date: 2.hours.ago,
          context: context,
          submissions: [submission]
        )
      end

      context "and the student has a submission" do
        let(:submission) { double('submission', student: student) }

        it 'will not grade the student' do
          expect(assignment).to_not receive(:grade_student)
          subject.call!
        end
      end

      context "and the student does not have a submission" do
        let(:submission) { double('submission', student: nil) }
        before do
          allow(assignment).to receive(:submissions).and_return([])
        end

        it "will zero out the student's grade" do
          expect(assignment).to receive(:grade_student).with(
            student,
              :score=>0,
              :grader=>"user"
            )
          subject.call!
        end
      end
    end
  end
end
