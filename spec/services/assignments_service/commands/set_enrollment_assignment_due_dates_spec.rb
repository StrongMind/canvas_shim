describe AssignmentsService::Commands::SetEnrollmentAssignmentDueDates do
  subject { described_class.new(enrollment: enrollment) }

  let(:enrollment_start_time) { course_start_date + 1.day }
  let(:enrollment) { double('Enrollment', created_at: enrollment_start_time, course: course, user: student) }
  let(:student) { User.create }
  let(:submission) { Submission.create(user: student) }
  let(:submission2) { Submission.create(user: student) }
  let(:assignment_override) { AssignmentOverride.create }
  let(:assignment_override2) { AssignmentOverride.create }
  let(:course_start_date) { Time.parse('2019-01-09 23:59:59.999999999 -0700') }

  let(:course) do
    Course.create(
      start_at: course_start_date,
      end_at: course_start_date + 4.days,
      assignments: [assignment, assignment2]
    )
  end

  let(:assignment) { Assignment.create(submissions: [submission], due_at: Time.now) }
  let(:assignment2) { Assignment.create(submissions: [submission2], due_at: Time.now) }

  before do
    allow(PipelineService).to receive(:publish)
    allow(SettingsService).to receive(:get_settings).and_return('enable_unit_grade_calculations' => false)
    instance = double(:query_instance, query: [assignment, assignment2])
    allow(AssignmentsService::Queries::AssignmentsWithDueDates).to receive(:new).and_return(instance)
  end

  describe "#call" do
    context 'feature flags' do
      context 'auto due dates' do
        before do
          allow(SettingsService).to receive(:get_settings).and_return('auto_due_dates' => 'on')
        end

        it 'does not create an assignment override' do
          expect(AssignmentOverrideStudent).to_not receive(:create)
          subject.call
        end
      end

      context 'auto enrollment due dates' do
        before do
          allow(SettingsService).to receive(:get_settings).and_return('auto_enrollment_due_dates' => 'on')
        end

        it 'does not create an assignment override' do
          expect(AssignmentOverrideStudent).to_not receive(:create)
          subject.call
        end
      end

    end

    context 'auto_enrollment_due_dates and auto_due_dates feature is switched on' do
      before do
        allow(SettingsService).to receive(:get_settings).and_return(
          'auto_due_dates' => 'on',
          'auto_enrollment_due_dates' => 'on'
        )
      end

      it 'creates assignment overrides' do
        subject.call
        expect(AssignmentOverride.count).to eq 2
        expect(AssignmentOverride.first.assignment_override_students.count).to eq 1
        expect(AssignmentOverride.first.due_at_overridden).to eq true
      end

      it 'creates a student override' do
        subject.call
        expect(AssignmentOverrideStudent.count).to eq 2
      end

      context 'course has no start date' do
        let(:course) { Course.create(start_at: nil) }

        it 'wont run' do
          expect(AssignmentOverrideStudent).to_not receive(:create)
          subject.call
        end
      end

      context 'enrollment starts before course' do
        let(:enrollment_start_time) { course_start_date - 1.day }

        it 'wont run' do
          expect(AssignmentOverrideStudent).to_not receive(:create)
          subject.call
        end
      end

      context 'assignment has no due date' do
        let(:assignment) { Assignment.create(submissions: [submission]) }
        let(:assignment2) { Assignment.create(submissions: [submission2]) }

        it 'wont run' do
          expect(AssignmentOverrideStudent).to_not receive(:create)
          subject.call
        end
      end
    end
  end
end
