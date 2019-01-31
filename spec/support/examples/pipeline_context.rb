RSpec.shared_context "pipeline_context" do
  before do
    allow(PipelineService).to receive(:publish)
    allow(SettingsService).to receive(:get_settings).and_return({})
  end
end
