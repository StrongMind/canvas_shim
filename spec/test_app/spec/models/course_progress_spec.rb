describe CourseProgress do
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

  describe "#find_observed_user" do
    before do
      allow(SettingsService).to receive(:get_settings).and_return({
        'auto_due_dates' => nil,
        'auto_enrollment_due_dates' => nil
      })
    end

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
    it "returns true if the user is enrolled as a student" do
      allow(course).to receive(:user_is_student?).and_return(true)
      expect(course_progress_student.send(:allow_course_progress?)).to be true
    end

    it "returns true if the user is observing a student" do
      allow(course).to receive(:user_is_student?).and_return(true)
      expect(course_progress_observer.send(:allow_course_progress?)).to be true
    end

    it "returns falsy if the user is not enrolled" do
      allow(course).to receive(:user_is_student?).and_return(false)
      expect(course_progress_student_2.send(:allow_course_progress?)).to be nil
    end
  end
end
