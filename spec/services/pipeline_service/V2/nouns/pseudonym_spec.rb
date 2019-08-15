describe PipelineService::V2::Nouns::Pseudonym do
  include_context "stubbed_network"

  subject { described_class.new(object: noun) }

  let(:User) { ::User.create }
  let!(:active_record_object) { ::Pseudonym.create(user_id: active_record_object.id, sis_user_id: '1234') }

  let(:noun) { PipelineService::V2::Noun.new(active_record_object)}

  describe '#call'do
    it 'returns with last login time' do
      expect(subject.call).to include({})
    end
  end
end
