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

  let!(:assigned_student) { User.create }
  let!(:unassigned_student) { User.create }
  let!(:course) { Course.create }

  let!(:assigned_student_enrollment) do
    Enrollment.create(
      type: "StudentEnrollment",
      user: assigned_student,
      course: course,
      workflow_state: "active"
    )
  end

  let!(:unassigned_student_enrollment) do
    Enrollment.create(
      type: "StudentEnrollment",
      user: unassigned_student,
      course: course,
      workflow_state: "active"
    )
  end
  
  let!(:assignment) do 
    Assignment.create(
      course: course
    )
  end

  let!(:settings) do
    {
      object: 'assignment',
      id: assignment.id,
      setting: 'unassigned_students',
      value: unassigned_student.id.to_s
    }
  end

  before do
    SettingsService.settings_table_prefix = 'integration.example.com'
    allow(SettingsService).to receive(:get_settings).and_return({})
  end

  describe "#send_unassigns_to_settings" do
    it "sends an id" do
      expect(SettingsService).to receive(:update_settings).with(settings)
      subject.send(:send_unassigns_to_settings)
    end

    it "sends false with nothing" do
      settings[:value] = false
      subject.instance_variable_set(:@new_unassigns, [])
      expect(SettingsService).to receive(:update_settings).with(settings)
      subject.send(:send_unassigns_to_settings)
    end

    context "Multiple unassigned" do
      let!(:unassigned_student_2) { User.create }
      let!(:unassigned_student_enrollment_2) do
        Enrollment.create(
          type: "StudentEnrollment",
          user: unassigned_student_2,
          course: course,
          workflow_state: "active"
        )
      end

      it "sends multiple with nothing" do
        settings[:value] = "#{unassigned_student_2.id},#{unassigned_student.id}"
        subject.instance_variable_set(:@new_unassigns, [unassigned_student_2.id.to_s, unassigned_student.id.to_s])
        expect(SettingsService).to receive(:update_settings).with(settings)
        subject.send(:send_unassigns_to_settings)
      end
    end
  end

  describe "#students_to_be_overridden" do
    it "gets the assigned user" do
      subject.instance_variable_set(:@all_unassigns, subject.send(:conjoin_unassigned_students))
      expect(subject.send(:students_to_be_overridden)).to eq(["#{assigned_student.id}"])
    end
  end

  describe "call" do
    it "mutates assignment_params when successful" do
      allow(SettingsService).to receive(:update_settings).with(settings)
      subject.call
      expect(subject.send(:assignment_params)[:only_visible_to_overrides]).to be(true)
    end
  end
end