describe ContextModuleProgression do
  include_context 'stubbed_network'
  let(:user) { User.create }
  let(:course) { Course.create }
  let(:context_module) { ContextModule.create!(context: course) }
  let(:context_module_progression) { ContextModuleProgression.create(context_module: context_module, user: user) }
  let!(:enrollment) { Enrollment.create(user: user, course: course) }

  before do
    allow(SettingsService).to receive(:get_enrollment_settings).and_return({"sequence_control"=>false})
  end

  describe "#prerequisites_satisfied?" do
    it 'returns true when sequence control is off' do
      expect(context_module_progression.prerequisites_satisfied?).to be(true)
    end
  end

  describe "#locked?" do
    it 'returns false when sequence control is off' do
      expect(context_module_progression.locked?).to be(false)
    end
  end

  context "Pipeline" do
    it 'publishes course progress to the pipeline' do
      expect(PipelineService).to receive(:publish)
      ContextModuleProgression.create(user: user, context_module: context_module)
    end

    it 'builds a course progress noun' do
      cmp = ContextModuleProgression.create(user: user, context_module: context_module)
      expect(PipelineService::Nouns::CourseProgress).to receive(:new).with(cmp)
      cmp.update(user: user)
    end
  end
end
