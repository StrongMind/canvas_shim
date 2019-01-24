describe CourseProgress do
  let(:user) { User.create }
  let(:user_2) { User.create }
  let(:observer) { User.create(observed_users: [user]) }
  let(:observer_2) { User.create(observed_users: [user, observer]) }
  let(:course) { Course.create }
  let(:course_progress_observer) { CourseProgress.new(course, observer) }
  let(:course_progress_observer_2) { CourseProgress.new(course, observer_2) }
  let(:course_progress_student) { CourseProgress.new(course, user) }
  let(:course_progress_student_2) { CourseProgress.new(course, user_2) }


  it 'playground' do
    # We're just playing with the public api
    course_progress_student.module_progressions
    course_progress_student.to_json
    course_progress_student.requirements
  end


  describe "#find_observed_user" do
    it 'returns the first observed user' do
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
