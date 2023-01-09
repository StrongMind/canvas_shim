describe Course do
  include_context "stubbed_network"

  describe "#after_commit" do
    it 'does publish to the pipeline' do
      expect(PipelineService).to receive(:publish)
      Course.create
    end
  end

  describe "#online_user_count" do
    let(:course) { Course.create }
    let(:user_1) { User.create }
    let(:user_2) { User.create }
    let(:user_3) { User.create }
    let(:enrollent_1) { Enrollment.create(course: course, user: user_1, workflow_state: 'active', type: 'StudentEnrollment') }
    let(:enrollent_2) { Enrollment.create(course: course, user: user_2, workflow_state: 'inactive', type: 'StudentEnrollment') }
    let(:enrollent_3) { Enrollment.create(course: course, user: user_3, workflow_state: 'active', type: 'TeacherEnrollment') }
    it "returns the count of 2 users online in the last 5 minutes of" do
      allow_any_instance_of(User).to receive(:is_online?).and_return(true)
      allow(enrollent_1).to receive(:workflow_state).and_return('active')
      allow(enrollent_2).to receive(:workflow_state).and_return('inactive')
      allow(enrollent_3).to receive(:workflow_state).and_return('active')
      expect(course.online_user_count).to eq(2)
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

  describe "#needs_grading_count" do
    let!(:course) { Course.create }


    it "returns all needs grading assignments" do
      3.times do
        Assignment.create(course: course)
      end

      allow_any_instance_of(Assignment).to receive(:needs_grading_count).and_return(3)
      expect(course.needs_grading_count).to eq(9)
    end

    it "returns 0 with no assignments needing grading" do
      expect(Course.create.needs_grading_count).to eq(0)
    end
  end

  describe "#snapshot_students" do
    let(:course) { Course.create }
    let(:user) { User.create(name: "Chris Young") }
    let!(:enrollment) { StudentEnrollment.create(user: user, course: course, workflow_state: "active") }
    let(:stu_arr) { [enrollment.id, user.id, user.name] }

    before do
      Pseudonym.create!(user: user, unique_id: "12345", sis_user_id: "12345")
      Pseudonym.create!(user: user, unique_id: "123456")
    end

    describe "#get_snapshot_sis_ids" do
      it "returns the plucked sis ids" do
        expect(course.send(:get_snapshot_sis_ids, stu_arr)).to eq(
          ["12345", nil]
        )
      end
    end

    it "concatenates sis_ids with plucked enrollment values" do
      expect(course.snapshot_students).to eq(
        [[enrollment.id, user.id, user.name, "12345", nil]]
      )
    end

    it "concatenates sis_ids with plucked enrollment values" do
      user.pseudonyms.last.update(sis_user_id: "23456")
      expect(course.snapshot_students).to eq(
        [[enrollment.id, user.id, user.name, "12345", "23456"]]
      )
    end

    it "concatenates sis_ids with plucked enrollment values" do
      user.update(pseudonyms: [])
      expect(course.snapshot_students).to eq(
        [[enrollment.id, user.id, user.name]]
      )
    end

    context "two users" do
      let(:user_2) { User.create(name: "Not Chris Young") }
      let!(:enrollment_2) { StudentEnrollment.create(user: user_2, course: course, workflow_state: "active") }

      before do
        Pseudonym.create!(user: user_2, unique_id: "12345", sis_user_id: "12345")
        Pseudonym.create!(user: user_2, sis_user_id: "23456")
        allow(user_2).to receive(:name).and_return("Not Chris Young")
      end

      it "creates a single row per user" do
        expect(course.snapshot_students.size).to eq(2)
      end
    end
  end

  describe "#check course start time" do
    context "course has start time" do
      before do
        allow(SettingsService).to receive(:get_settings).and_return({'course_start_time_hour' => "5",
                                                                     'course_start_time_minute' => "55",
                                                                     'course_time_ampm' => "PM"})
      end

      date_param = DateTime.new(2023, 5, 18, 3, 33, 0, Time.zone.now.formatted_offset)
      let(:course) { Course.create(start_at: date_param) }

      it "matches start time in account settings" do
        expected_start_time = "17:55 PM"
        actual_start_time = course.start_at.strftime("%H:%M %p")
        expect(actual_start_time).to eq(expected_start_time)
      end
    end

    context "course start time is nil" do
      let(:course) { Course.create() }
      it "creates a course without a start_at" do
        expect(course.start_at).to be nil
      end
    end

  end
end
