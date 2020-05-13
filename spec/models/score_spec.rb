describe Score do
  include_context "stubbed_network"

  describe "#score" do
    it 'does publish to the pipeline' do
      expect(PipelineService::V2).to receive(:publish)
      Score.create
    end
  end
end
