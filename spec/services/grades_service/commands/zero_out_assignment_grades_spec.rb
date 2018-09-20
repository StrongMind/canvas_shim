class Account
end

describe GradesService::Commands::ZeroOutAssignmentGrades do
  describe '#call' do
    let(:account_instance) {
      double(
        'default_account',
        feature_enabled?: true,
        account_users:        [
          Struct.new(:role, :user).new(
            Struct.new(:name).new('AccountAdmin'),
              'account admin user'
            )
        ]
      )
    }
    let(:student)  { double('student', id: 1) }
    let(:context)  { double('context', students: [student]) }
    let(:students) { [student] }
    let(:submissions) { [submission] }
    let(:submission) { double('submission2', student: student, state: '', workflow_state: 'submitted') }

    subject { described_class.new(1) }

    before do
      allow(SettingsService).to receive(:get_settings).and_return({'zero_out_past_due' => 'on'})
      allow(Account).to receive(:default).and_return(account_instance)
      allow(::Assignment).to receive(:find).and_return(assignment)
      ENV['CANVAS_DOMAIN'] = 'somedomain'
      allow(SettingsService).to receive(:update_settings)
    end

    context "when the assignment is on time" do
      let(:assignment) { double('assignment', due_date: Time.zone.now, published?: true)}

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
          submissions: submissions,
          published?: true,
          id: 2
        )
      end

      before do
        allow(submissions).to receive(:find_by).and_return(double('submission1', score: 30))
      end

      context "and the assignment isnt published" do
        let(:assignment) do
          double(
            'past due assignment, with student submission',
            due_date: 2.hours.ago,
            context: context,
            published?: false,
            submissions: []
          )
        end
        it "do nothing" do
          expect(subject).to_not receive(:students_without_submissions)
          subject.call!
        end
      end

      context "and the submission has been submitted" do
        let(:submission) { double('submission2', student: student, state: '', workflow_state: 'submitted') }

        it 'will not grade the student' do
          expect(assignment).to_not receive(:grade_student)
          subject.call!
        end
      end

      context "and the submission has been graded" do
        let(:submission) { double('submission', student: student, state: '', workflow_state: 'graded') }

        it 'will not grade the student' do
          expect(assignment).to_not receive(:grade_student)
          subject.call!
        end
      end

      context "and the submission has a score" do
        let(:submission) { double('submission', student: student, state: '', workflow_state: 'junk', score: 50, grade: nil) }

        it 'will not grade the student' do
          expect(assignment).to_not receive(:grade_student)
          subject.call!
        end
      end

      context "and the submission has a grade" do
        let(:submission) { double('submission', student: student, state: '', workflow_state: 'junk', grade: 50, score: nil) }

        it 'will not grade the student' do
          expect(assignment).to_not receive(:grade_student)
          subject.call!
        end
      end

      context "and the student does not have a submission" do
        let(:submissions) {[]}
        before do
          allow(submissions).to receive(:find_by).and_return nil
          allow(assignment).to receive(:submissions).and_return(submissions)
        end

        it "will zero out the student's grade" do
          expect(assignment).to receive(:grade_student).with(
            student,
            score: 0,
            grader: "account admin user"
          )
          subject.call!
        end
      end

      context 'assignment does not have a due date' do
        before do
          allow(assignment).to receive(:submissions).and_return([])
        end

        let(:assignment) do
           double('assignment', due_date: nil, published?: true, context: context)
        end

        it "will not zero out the student's grade" do
          expect(assignment).to_not receive(:grade_student).with(
            student,
            score: 0,
            grader: "account admin user"
          )
          subject.call!
        end
      end

      context 'submission is not in a submitted state' do
        before(:each) do
          allow(assignment).to receive(:submissions).and_return(submissions)
          allow(assignment).to receive(:grade_student)
          allow(SettingsService).to receive(:update_settings)
          allow(submissions).to receive(:find_by).and_return(submission)
        end

        let(:submission) do
          double('submission4', student: student, workflow_state: 'junk', score: nil, grade: nil )
        end

        it "will zero out the student's grade" do

          expect(assignment).to receive(:grade_student).with(
            student,
            score: 0,
            grader: "account admin user"
          )
          subject.call!
        end

      end

      context "Logging" do
        before(:each) do
          allow(assignment).to receive(:grade_student)
        end

        let(:submission) do
          double('submission4', student: student, workflow_state: 'junk', score: nil, grade: nil )
        end
        context "Zeroed out scores" do
          before do
            allow(submissions).to receive(:find_by).and_return(double('submission1', score: nil))
          end

          it "records true" do
            expect(SettingsService).to receive(:update_settings).with(hash_including(value: true))

            subject.call!
          end
        end
        context "Pre-existing Grades" do
          before do
            allow(submissions).to receive(:find_by).and_return(double('submission1', score: 0))
          end

          it "records false" do
            expect(SettingsService).to receive(:update_settings).with(hash_including(value: false))
            subject.call!
          end
        end
      end
    end
  end
end
