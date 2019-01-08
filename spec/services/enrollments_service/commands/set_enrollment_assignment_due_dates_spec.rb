describe CoursesService::Commands::SetEnrollmentAssignmentDueDates do
  subject { described_class.new(enrollment: enrollment) }

  let(:enrollment) { double('Enrollment', start_at: Time.now, course: course) }
  let(:student) { double('Student') }
  let(:submission) { double('submission', student: student) }
  let(:course) do
    double('Course',
      start_at: Time.now,
      assignments: [assignment],
      enrollments: [enrollment]
    )
  end
  let(:assignment) { double('Assignment', submissions: [submission]) }

  describe "#call" do
    it 'creates assignment override' do
      expect(AssignmentOverride).to receive(:create).with(assignment)
      subject.call
    end

    it 'creates a student override' do
      expect(AssignmentOverrideStudent).to receive(:create).with(
        assignment_override: assignment_override,
        assignment: assignment,
        user: student
      )
    end
  end
end
