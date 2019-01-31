describe PipelineService::Serializers::ConversationMessage do
  include_context "pipeline_context"

  subject { described_class.new(object: conversation_message_model) }

  let(:conversation_message_model) { ConversationMessage.create! }

  it 'calls the canvas api for a conversation_message' do
    expect(JSON.parse(subject.call)).to include( { 'id' => conversation_message_model.id } )
  end
end
