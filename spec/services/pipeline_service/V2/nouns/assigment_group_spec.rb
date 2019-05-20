describe PipelineService::V2::Nouns::AssignmentGroup do
  include_context "stubbed_network"


  subject { described_class.new(object: noun) }
  let(:active_record_object)  { AssignmentGroup.new(context_id: 1, context_type: 'bob') }
  let(:noun) { PipelineService::V2::Noun.new(active_record_object)}

  describe '#call'do
    it 'transforms id' do
      expect(subject.call).to include({:bob_id => 1})
    end
  end
end
