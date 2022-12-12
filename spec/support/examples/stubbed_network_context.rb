RSpec.shared_context "stubbed_network" do
  before do
    allow(PipelineService::V2).to receive(:publish)
    allow(PipelineService).to receive(:publish)
    allow(SettingsService).to receive(:get_settings).and_return({})
    allow(SettingsService).to receive(:update_settings).and_return({})
    allow(HTTParty).to receive(:post)
    allow(PipelineService::HTTPClient).to receive(:post)
    allow(PipelineService::HTTPClient).to receive(:get).and_return(double('response', parsed_response: ''))
  end
end
