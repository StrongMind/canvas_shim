describe Course do
  include_context "stubbed_network"

  describe "#after_commit" do
    it 'does publish to the pipeline' do
      expect(PipelineService).to receive(:publish)
      Course.create
    end
  end

  describe "#no_active_students" do
    let(:first_user) { User.create }
    context "inactive student course" do
      let(:inactive_course) { Course.create }
      let(:inactive_enrollment_1) { Enrollment.create(course: inactive_course, user: first_user, workflow_state: 'invited', type: 'StudentEnrollment') }

      it "works with an inactive enrollment" do
        expect(inactive_course.no_active_students?).to be true
      end

      it "works with no enrollments" do
        expect(Course.create.no_active_students?).to be true
      end
    end

    context "active course" do
      let(:active_course) { Course.create }
      let!(:active_enrollment_1) { Enrollment.create(course: active_course, user: first_user, workflow_state: 'active', type: 'StudentEnrollment') }

      it "returns false when students are active in course" do
        expect(active_course.no_active_students?).to be false
      end
    end
  end
end
