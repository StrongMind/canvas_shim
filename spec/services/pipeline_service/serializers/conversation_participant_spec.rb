describe PipelineService::Serializers::ConversationParticipant do
  include_context "pipeline_context"

  subject { described_class.new(object: conversation_participant_model) }

  let(:conversation_participant_model) { ConversationParticipant.create(conversation: Conversation.create) }

  it 'Return a json hash of the noun' do
    expect(subject.call).to include( "id" => conversation_participant_model.id )
  end

  it '#additional_identifiers' do
    subject.call
    expect(subject.additional_identifiers).to include( 'conversation_id' => conversation_participant_model.conversation_id)
  end
end
