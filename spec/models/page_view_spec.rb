describe PageView do
  include_context "stubbed_network"

  describe "#after_commit" do

    it 'publishes to the pipeline' do
      expect(PipelineService).to receive(:publish)
      PageView.create
    end

  end
end
