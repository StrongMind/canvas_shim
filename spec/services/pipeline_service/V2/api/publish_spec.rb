describe PipelineService::V2::API::Publish do
  include_context 'stubbed_network'

  let(:command) { double("command", call: nil) }
  
  describe '#publish' do
    before do
      allow(SettingsService).to receive(:update_settings)
    end

    it 'calls the command' do
      expect(PipelineService::V2::Commands::PublishToPipeline).to receive(:new).and_return(command)
      described_class.new(PageView.create).call
    end
  end
end
