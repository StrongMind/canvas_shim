describe Course do
  include_context "stubbed_network"

  describe "#after_commit" do
    it 'does publish to the pipeline' do
      expect(PipelineService).to receive(:publish)
      AssignmentGroup.create
    end
  end
end
