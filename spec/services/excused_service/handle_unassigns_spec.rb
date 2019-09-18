describe ExcusedService::Commands::HandleUnassigns do
  include_context 'stubbed_network'

  subject do
    described_class.new(
      assignment: assignment,
      assignment_params: {
        :assignment_overrides => [],
        :bulk_unassign => ["#{unassigned_student_enrollment.user_id}"]
      }
    )
  end

  let!(:student) { User.create }
  let!(:course) { Course.create }

  let!(:assigned_student_enrollment) do
    Enrollment.create(
      type: "StudentEnrollment",
      user: student,
      course: course,
      workflow_state: "active"
    )
  end

  let!(:unassigned_student_enrollment) do
    Enrollment.create(
      type: "StudentEnrollment",
      user: student,
      course: course,
      workflow_state: "active"
    )
  end
  
  let!(:assignment) do 
    Assignment.create(
      course: course
    )
  end

  describe "#send_unassigns_to_settings" do
    let(:settings) do
      {
        object: 'assignment',
        id: assignment.id,
        setting: 'unassigned_students',
        value: student.id.to_s
      }
    end
  
    before do
      allow(SettingsService).to receive(:get_settings).and_return({})
    end

    it "sends an id" do
      expect(SettingsService).to receive(:update_settings).with(settings)
      subject.send(:send_unassigns_to_settings)
    end
  end
end