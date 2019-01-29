RSpec.shared_context "pipeline_context" do
  before do
    allow(PipelineService).to receive(:publish)
    allow(SettingsService).to receive(:get_settings).and_return({})
    allow(Pandarus::Client).to receive(:new).and_return(api_instance)
  end
end
