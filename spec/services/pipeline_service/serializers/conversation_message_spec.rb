describe PipelineService::Serializers::ConversationMessage do
  include_context "pipeline_context"

  subject { described_class.new(object: conversation_message_model) }

  let(:conversation_message_model) { ConversationMessage.create! }

  it 'Return a json hash of the noun' do
    expect(JSON.parse(subject.call)).to include( { 'id' => conversation_message_model.id } )
  end
end
