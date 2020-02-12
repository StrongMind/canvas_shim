describe PipelineService::V2::Nouns::Base do
  include_context "stubbed_network"

  # lets override as_json, like canvas do
  class PageViewWithJSONOverride < PageView
    def as_json
      {foo: 'bar'}
    end
  end

  subject { described_class.new(object: noun) }

  let(:active_record_object) { PageViewWithJSONOverride.create! }
  
  let(:noun) { PipelineService::V2::Noun.new(active_record_object)}

  describe '#call'do
    before do
      allow(SettingsService).to receive(:update_settings)
    end

    it 'returns base level json (not anything overridden)' do
      expect(subject.call).to eq('request_id' => active_record_object.id)
    end
  end
end
