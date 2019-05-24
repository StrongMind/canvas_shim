describe DiscussionTopic do
  include_context "stubbed_network"

  describe "#after_commit" do
    it 'does publish to the pipeline' do
      expect(PipelineService).to receive(:publish)
      DiscussionTopic.create(context: Course.create)
    end
  end
end
