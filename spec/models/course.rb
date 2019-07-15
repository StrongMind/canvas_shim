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

  describe "#set_default_course_threshold" do
    before do
      allow_any_instance_of(Course).to receive(:set_default_course_threshold).and_return(nil)
    end
    
    context "account threshold is set" do
      before do
        allow_any_instance_of(Course).to receive(:account_threshold).and_return(60.0)
      end

      it "sets a default threshold" do
        course = Course.new
        expect(course).to receive(:set_default_course_threshold)
        course.save
      end
    end

    context "account threshold is not set" do
      before do
        allow_any_instance_of(Course).to receive(:account_threshold).and_return(0.0)
      end

      it "does not set a default threshold" do
        course = Course.new
        expect(course).not_to receive(:set_default_course_threshold)
        course.save
      end
    end
  end

  describe "#average_score" do
    let!(:course) { Course.create }
    let!(:student) { User.create }
    let!(:student_enrollment) do
      StudentEnrollment.create(course: course, user: student, workflow_state: "active")
    end
    let!(:score_1) { Score.create(enrollment: student_enrollment, current_score: 87.0)}

    it "gets an average" do
      expect(course.average_score).to eq(87.0)
    end

    context "multiple students" do
      let!(:student_enrollment_2) do
        StudentEnrollment.create(course: course, user: student, workflow_state: "active")
      end
      let!(:score_2) { Score.create(enrollment: student_enrollment_2, current_score: 50.0)}
      let!(:student_enrollment_3) do
        StudentEnrollment.create(course: course, user: student, workflow_state: "active")
      end
      let!(:score_3) { Score.create(enrollment: student_enrollment_3, current_score: 60.0)}

      it "is different now" do
        expect(course.average_score.round(1)).to eq(65.7)
      end
    end

    it "returns 0 with no students" do
      expect(Course.create.average_score).to eq(0)
    end
  end
end
