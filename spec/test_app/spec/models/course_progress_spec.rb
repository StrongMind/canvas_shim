describe CourseProgress do
  include_context 'pipeline_context'
  let(:user) { User.create }
  let(:user_2) { User.create }
  let(:observer) { User.create(observed_users: [user]) }
  let(:observer_2) { User.create(observed_users: [user, observer]) }
  let(:course) { Course.create }
  let(:course_progress_observer) { CourseProgress.new(course, observer) }
  let(:observer_enrollment) { Enrollment.create(user: observer, course: course, type: 'ObserverEnrollment', associated_user_id: user.id) }
  let(:course_progress_observer_2) { CourseProgress.new(course, observer_2) }
  let(:observer_enrollment_3) { Enrollment.create(user: observer_2, course: course, type: 'ObserverEnrollment', associated_user_id: observer.id) }
  let(:course_progress_student) { CourseProgress.new(course, user) }
  let(:student_enrollment) { Enrollment.create(user: user, course: course, type: 'StudentEnrollment') }
  let(:course_progress_student_2) { CourseProgress.new(course, user_2) }

  describe "#find_user_id" do
    it 'returns the first observed user' do
      Enrollment.create(user: observer, course: course, type: 'ObserverEnrollment', associated_user_id: user.id)
      Enrollment.create(user: observer_2, course: course, type: 'ObserverEnrollment', associated_user_id: user.id)
      expect(course_progress_observer.send(:find_user_id)).to eq(user.id)
      expect(course_progress_observer_2.send(:find_user_id)).to eq(user.id)
    end

    it 'returns the user if they have no observers' do
      expect(course_progress_student.send(:find_user_id)).to eq(user.id)
    end
  end

  describe "#allow_course_progress?" do
    before do
      Enrollment.create(user: observer, course: course, type: 'ObserverEnrollment', associated_user_id: user.id)
      Enrollment.create(user: observer_2, course: course, type: 'ObserverEnrollment', associated_user_id: user.id)
    end

    it "returns true if the user is enrolled as a student" do
      expect(course).to receive(:user_is_student?).with(user, :include_all=>true).and_return(true)
      expect(course_progress_student.send(:allow_course_progress?)).to be true
    end

    it "returns true if the user is observing a student" do
      expect(course).to receive(:user_is_student?).with(observer, :include_all=>true).and_return(false)
      expect(course).to receive(:user_is_student?).with(user, :include_all=>true).and_return(true)
      expect(course_progress_observer.send(:allow_course_progress?)).to be true
    end
  end

  describe "#excused_submission_count" do
    context "with excused submission" do
      let(:excused_submission_count) { rand(2..5) }

      it "counts excused submissions" do
        excused_submission_count.times do
          Submission.create!(user: user, assignment: Assignment.create(course: course), excused: true)
        end

        expect(course_progress_student.send(:excused_submission_count)).to eq excused_submission_count
      end
    end
  end

  describe "#requirement_count" do
    context "with excused submission" do
      before do
        excused_submission_count.times do
          Submission.create!(user: user, assignment: Assignment.create(course: course), excused: true)
        end
      end

      let(:excused_submission_count) { 6 }
      let(:fake_requirements) { Array.new(excused_submission_count + 1) }

      it "subtracts excused submissions from requirement count" do
        allow(course_progress_student).to receive(:requirements).and_return(fake_requirements)
        expect(course_progress_student.requirement_count).to eq 1
      end
    end
  end
end
