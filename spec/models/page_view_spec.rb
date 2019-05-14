describe PageView do
  include_context "stubbed_network"

  describe "#after_commit" do

  context "when page view publishing is featured" do
    before do
      allow(SettingsService).to receive(:get_settings).and_return({'publish_page_views' => true})
    end
    it 'publishes to the pipeline' do
      expect(PipelineService::V2).to receive(:publish)
      PageView.create
    end
  end

  context "when page view publishing is unfeatured" do
    it 'does publish to the pipeline' do
      expect(PipelineService::V2).to_not receive(:publish)
      PageView.create
    end
  end

  end
end
