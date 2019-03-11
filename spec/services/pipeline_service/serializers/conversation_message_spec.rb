describe PipelineService::Serializers::ConversationMessage do
  include_context "pipeline_context"

  subject { described_class.new(object: active_record_object) }

  let(:active_record_object) { ConversationMessage.create!(conversation: Conversation.create!) }

  it 'Return an attribute hash of the noun' do
    expect(subject.call).to include( { 'id' => active_record_object.id } )
  end

  it 'has additional identifiers' do
    subject.call
    expect(subject.additional_identifiers).to eq(
      'conversation_id' => active_record_object.conversation_id
    )
  end

  context 'deleted object' do
    it 'does not have additional identifiers if the conversation was deleted' do
      destroyed_object = active_record_object.destroy!
      subject = described_class.new(object: destroyed_object)
      subject.call
      expect(subject.additional_identifiers).to eq({})
    end
  end
end
