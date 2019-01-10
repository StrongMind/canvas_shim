describe AssignmentsService::Commands::SetEnrollmentAssignmentDueDates do
  subject { described_class.new(enrollment: enrollment) }

  let(:enrollment_start_time) { course_start_date + 1.day }
  let(:enrollment) { double('Enrollment', start_at: enrollment_start_time, course: course, user: student) }
  let(:student) { User.create }
  let(:submission) { Submission.create(user: student) }
  let(:submission2) { Submission.create(user: student) }
  let(:assignment_override) { AssignmentOverride.create }
  let(:assignment_override2) { AssignmentOverride.create }
  let(:course_start_date) { Time.parse('2019-01-09 23:59:59.999999999 -0700') }

  let(:course) do
    Course.create(
      start_at: course_start_date,
      end_at: course_start_date + 60.days,
      assignments: [assignment, assignment2]
    )
  end

  let(:assignment) { Assignment.create(submissions: [submission]) }
  let(:assignment2) { Assignment.create(submissions: [submission2]) }

  before do
    allow(SettingsService).to receive(:get_settings).and_return('enable_unit_grade_calculations' => false)
    allow(AssignmentOverride).to receive(:create).and_return(assignment_override)
    allow(AssignmentOverride).to receive(:create).and_return(assignment_override2)
  end

  describe "#call" do
    it 'creates assignment override' do
      expect(AssignmentOverride).to receive(:create).with(
        assignment: assignment,
        due_at: Time.parse('2019-01-11 23:59:59.999999999 -0700')
      )

      expect(AssignmentOverride).to receive(:create).with(
        assignment: assignment2,
        due_at: Time.parse('2019-01-14 23:59:59.999999999 -0700')
      )

      subject.call
    end

    it 'creates a student override' do
      expect(AssignmentOverrideStudent).to receive(:create).with(
        assignment_override: assignment_override,
        assignment: assignment,
        user: student
      )
      expect(AssignmentOverrideStudent).to receive(:create).with(
        assignment_override: assignment_override,
        assignment: assignment2,
        user: student
      )
      subject.call
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
  end
end
