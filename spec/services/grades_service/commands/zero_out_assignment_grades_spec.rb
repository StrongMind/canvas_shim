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
    let(:student)  { double('student') }
    let(:context)  { double('context', students: [student]) }
    let(:students) { [student] }

    subject { described_class.new(assignment) }

    before do
      allow(SettingsService).to receive(:get_settings).and_return({'zero_out_past_due' => 'on'})
      allow(Account).to receive(:default).and_return(account_instance)
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
          submissions: [submission],
          published?: true
        )
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
        let(:submission) { double('submission', student: student, state: '', workflow_state: 'submitted') }

        it 'will not grade the student' do
          expect(assignment).to_not receive(:grade_student)
          subject.call!
        end
      end

      context "and the student does not have a submission" do
        before do
          allow(assignment).to receive(:submissions).and_return([])
        end

        let(:submission) { double('submission', student: nil) }

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

        it "will zero out the student's grade" do
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
          allow(assignment).to receive(:submissions).and_return([submission])
        end

        let(:submission) do
          double('submission', student: student, workflow_state: 'junk' )
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
    end
  end
end
