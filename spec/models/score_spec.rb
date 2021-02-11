describe Score do
  include_context "stubbed_network"
  let!(:course) { Course.create }
  let!(:user) { User.create }
  let!(:enrollment) { StudentEnrollment.create(type: 'StudentEnrollment', course: course, user: user, scores: [score])}
  let!(:score) { Score.create(enrollment: enrollment)}


  describe "#On score commit" do
    it "Publishes enrollment noun" do
      expect(PipelineService).to receive(:publish_as_v2)
      score.touch
    end
  end

end