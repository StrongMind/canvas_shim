describe ContextModuleProgression do
  include_context 'stubbed_network'
  let(:user) { User.create }
  let(:course) { Course.create }
  let!(:context_module) { ContextModule.create!(context: course) }
  let(:context_module_progression) { ContextModuleProgression.create(context_module: context_module, user: user) }
  let!(:enrollment) { Enrollment.create(user: user, course: course, type: 'StudentEnrollment') }

  before do
    allow(SettingsService).to receive(:get_enrollment_settings).and_return({"sequence_control"=>false})
  end

  describe "#locked?" do
    it 'returns false when sequence control is off' do
      expect(context_module_progression.locked?).to be(false)
    end
  end

  it 'publishes to the pipeline' do
    cmp = ContextModuleProgression.new(user: user, context_module: context_module)
    expect(PipelineService::V2).to receive(:publish).with (cmp)
    cmp.save
  end

  it 'publishes course_progress to the pipeline' do
    cmp = ContextModuleProgression.new(user: user, context_module: context_module)
    expect(PipelineService).to receive(:publish_as_v2).with instance_of(PipelineService::Nouns::CourseProgress)
    cmp.save
  end

end
