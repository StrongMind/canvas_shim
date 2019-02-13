describe PipelineService::Serializers::ConversationParticipant do
  include_context "pipeline_context"

  subject { described_class.new(object: noun) }

  let(:conversation_participant_model) { ConversationParticipant.create(conversation_id: 5) }

  let(:noun) { PipelineService::Models::Noun.new(conversation_participant_model) }

  it 'Return a json hash of the noun' do
    expect(subject.call).to include( "id" => conversation_participant_model.id )
  end

  it '#additional_identifiers' do
    subject.call
    expect(subject.additional_identifiers).to include('conversation_id' => 5)
  end
end
