describe CourseProgress do
  let(:user) { User.create }
  let(:user_2) { User.create }
  let(:observer) { User.create(observed_users: [user]) }
  let(:observer_2) { User.create(observed_users: [user, observer]) }
  let(:course) { Course.create }
  let(:cpo) { CourseProgress.new(course, observer) }
  let(:cpo_2) { CourseProgress.new(course, observer_2) }
  let(:cpu) { CourseProgress.new(course, user) }
  let(:cpu_2) { CourseProgress.new(course, user_2) }


  it 'playground' do
    # We're just playing with the public api
    cpu.module_progressions
    cpu.to_json
    cpu.requirements
  end


  describe "#find_observed_user" do
    it 'returns the first observed user' do
      expect(cpo.send(:find_user_id)).to eq(user.id)
      expect(cpo_2.send(:find_user_id)).to eq(user.id)
    end

    it 'returns the user if no observers' do
      expect(cpu.send(:find_user_id)).to eq(user.id)
    end
  end

  describe "#allow_course_progress?" do
    it "returns true if the user is enrolled as a student" do
      allow(course).to receive(:user_is_student?).and_return(true)
      expect(cpu.send(:allow_course_progress?)).to be true
    end

    it "returns true if the user is observing a student" do
      allow(course).to receive(:user_is_student?).and_return(true)
      expect(cpo.send(:allow_course_progress?)).to be true
    end

    it "returns falsy if the user is not enrolled" do
      allow(course).to receive(:user_is_student?).and_return(false)
      expect(cpu_2.send(:allow_course_progress?)).to be nil
    end
  end
end
