describe CourseProgress do
  let(:user) { User.create }
  let(:observer) { User.create }
  let(:course) { Course.create }

  it 'playground' do
    # We're just playing with the public api
    CourseProgress.new(course, user).module_progressions
    CourseProgress.new(course, user).to_json
    CourseProgress.new(course, user).requirements
  end


  describe "#find_observed_user" do
    it 'returns the first observed user' do

    end

    it 'returns nil' do
      #
    end
  end

  describe "#set_user_id" do
    # expect instance.send(:set_user_id).to eq(user.id)
    it "returns observed user id" do

    end

    it "returns user id" do

    end
  end

  describe "#allow_course_progress?" do
    it "returns true" do

    end

    it "returns false" do

    end
  end
end
