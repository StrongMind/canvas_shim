describe PipelineService::Serializers::ConversationMessage do
  include_context "pipeline_context"

  subject { described_class.new(object: conversation_message_model) }

  let(:conversation_message_model) { ConversationMessage.create!(conversation: Conversation.create!) }

  it 'Return an attribute hash of the noun' do
    expect(subject.call).to include( { 'id' => conversation_message_model.id } )
  end

  it 'has the conversation message' do
    expect(subject.additional_identifiers).to eq(
      conversation_id: conversation_message_model.conversation_id
    )
  end
end
