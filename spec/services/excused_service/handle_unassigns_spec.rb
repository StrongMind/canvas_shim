describe ExcusedService::Commands::HandleUnassigns do
  include_context 'stubbed_network'

  subject do
    described_class.new(
      assignment: assignment,
      assignment_params: {
        :assignment_overrides => [],
        :bulk_unassign => [
          { name: "student", id: "#{unassigned_student_enrollment.user_id}" }
        ]
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
      id: assignment.id.to_s,
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

    it "publishes an unassignmed message to the pipeline" do
      allow(SettingsService).to receive(:update_settings).with(settings)
      expect(PipelineService).to receive(:publish)
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

      it "Filters out previous unassigns that are not in current params" do
        settings[:value] = "-26,#{unassigned_student_2.id},#{unassigned_student.id}"
        subject.instance_variable_set(:@previous_unassigns, '-25,-26')
        subject.instance_variable_set(:@new_unassigns, ["-26", unassigned_student_2.id.to_s, unassigned_student.id.to_s])
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

  describe "#remove_unassigns_from_overrides" do
    it "removes the assignment override if the student is bulk unassigned" do
      subject.send(:assignment_params)[:assignment_overrides] = [
        { "student_ids" => ["#{unassigned_student_enrollment.user_id}"] }
      ]

      subject.send(:remove_unassigns_from_overrides)
      expect(subject.send(:assignment_params)[:assignment_overrides].first["student_ids"].size).to eq 0
    end
  end

  describe "call" do
    before do
      allow(SettingsService).to receive(:update_settings).with(settings)
    end

    it "mutates assignment_params when successful" do
      subject.call
      expect(subject.send(:assignment_params)[:only_visible_to_overrides]).to be(true)
    end

    it "does not execure without variables" do
      subject.instance_variable_set(:@assignment, nil)
      expect(subject).to_not receive(:send_unassigns_to_settings)
      subject.call
    end

    it "saves the assignment_override params with no due date" do
      subject.call
      expectation = [
        { "due_at"=>nil,
          "due_at_overridden"=>true,
          "lock_at"=>nil,
          "lock_at_overridden"=>false,
          "unlock_at"=>nil,
          "unlock_at_overridden"=>false,
          "rowKey"=>"",
          "student_ids"=>["#{assigned_student.id}"],
          "all_day"=>false,
          "all_day_date"=>nil,
          "persisted"=>false }
        ]
      expect(subject.send(:assignment_params)[:assignment_overrides]).to eq(expectation)
    end

    it "uses an original due date" do
       original_due_date = Time.now
       allow(SettingsService).to receive(:get_settings).and_return({"original_due_date" => original_due_date})
       subject.call
       expectation = [
         { "due_at"=>original_due_date,
           "due_at_overridden"=>true,
           "lock_at"=>nil,
           "lock_at_overridden"=>false,
           "unlock_at"=>nil,
           "unlock_at_overridden"=>false,
           "rowKey"=>"",
           "student_ids"=>["#{assigned_student.id}"],
           "all_day"=>false,
           "all_day_date"=>nil,
           "persisted"=>false }
        ]
      expect(subject.send(:assignment_params)[:assignment_overrides]).to eq(expectation)
    end
  end
end