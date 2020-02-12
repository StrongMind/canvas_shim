describe PageView do
  include_context "stubbed_network"

  describe "#after_commit" do
    let(:user) {User.create}

    before do
      allow(SettingsService).to receive(:update_settings)
    end

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

    it 'updates the users last access time' do
        Timecop.freeze
        current_time = Time.now.utc
        expect(Rails.cache).to receive(:write).with("1/last_access_time", current_time, {:expires_in=> 5.minutes})
        PageView.create
        Timecop.return
    end

  end
end
