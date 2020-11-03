describe PipelineService::V2::Nouns::ContentTag do
  include_context "stubbed_network"

  subject { described_class.new(object: noun) }

  let(:active_record_object) { ::ContentTag.create }

  let(:noun) { PipelineService::V2::Noun.new(active_record_object)}

  describe '#call'do
    it 'returns with resource_link_id' do
      expect(subject.call).to include({'resource_link_id' => '123456789123456789'})
    end
    it 'includes published_at' do
      expect(subject.call).to eq({})
    end
  end
end
