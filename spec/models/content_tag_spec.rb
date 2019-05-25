describe ContentTag do
  include_context "stubbed_network"

  describe "#after_commit" do
    it 'does publish to the pipeline' do
      expect(PipelineService::V2).to receive(:publish)
      ContentTag.create(context: Course.create)
    end

    it 'publishes content_modules_item' do
      expect(PipelineService).to receive(:publish)
      ContentTag.create
    end

    it 'uses the Context' do
      ct = ContentTag.create
      expect(PipelineService::Nouns::ContextModuleItem).to receive(:new).with(ct)
      ContentTag.update(content_id: 100)
    end
  end
end
