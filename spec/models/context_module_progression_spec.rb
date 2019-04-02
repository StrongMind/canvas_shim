describe ContextModuleProgression do
  include_context 'stubbed_network'
  let(:user) { User.create }
  let(:course) { Course.create }
  let(:context_module) { ContextModule.create(context: course) }
  let(:context_module_progression) { ContextModuleProgression.create(context_module: context_module, user: user) }
  let!(:enrollment) { Enrollment.create(user: user, course: course) }

  before do
    allow(SettingsService).to receive(:get_enrollment_settings).and_return({"sequence_control"=>false})
  end

  it 'returns true with no setting' do
    expect(context_module_progression.prerequisites_satisfied?).to be(true)
  end
end
