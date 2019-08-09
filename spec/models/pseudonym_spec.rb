describe Pseudonym do
  include_context "stubbed_network"

  describe "#after_commit" do
    it 'publishes to the pipeline' do
      expect(PipelineService::V2).to receive(:publish)
      Pseudonym.create
    end
  end
end
