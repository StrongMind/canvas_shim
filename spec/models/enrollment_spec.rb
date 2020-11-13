describe Enrollment do
  include_context "stubbed_network"
  let(:assignment) { Assignment.create }
  let(:course) { Course.create(assignments: [assignment]) }
  let(:command) { double("Command", perform: nil)}
  let(:user) { User.create }

  it 'calls when created' do
    expect(AssignmentsService::Commands::SetEnrollmentAssignmentDueDates).to receive(:new).and_return(command)
    described_class.create(course: course, user: user)
  end


  it 'will run in the background' do
    expect(Delayed::Job).to receive(:enqueue)
    described_class.create(course: course, user: user)
  end

  describe "#after_commit" do
    let(:enrollment) { Enrollment.create(course: course, user: user, type: "StudentEnrollment", workflow_state: "active") }

    it "reactivates deleted scores when active" do
      Score.create(enrollment: enrollment, workflow_state: "deleted")
      enrollment.save
      expect(Score.first.workflow_state).to eq("active")
    end

    it "does not run on active scores" do
      Score.create(enrollment: enrollment, workflow_state: "active")
      enrollment.save
      expect(Score.first).not_to receive(:update)
    end
  end

  it "publishes as v2 on create" do
    expect(PipelineService).to receive(:publish_as_v2)
    Enrollment.create
  end
end
