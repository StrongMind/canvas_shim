describe ContextModuleProgression do
  include_context "stubbed_network"

  let!(:user) { ::User.create }
  let!(:course) { ::Course.create }
  let!(:enrollment) { ::Enrollment.create(user: user, course: course, type: 'StudentEnrollment')}
  let!(:cm) { ::ContextModule.create(context_id: course.id, context_type: 'Course') }

  describe "#after_commit" do
    it 'does publish to the pipeline' do
      expect(PipelineService::V2).to receive(:publish)
      ContextModuleProgression.create(user: user, context_module: cm)
    end
  end
end
