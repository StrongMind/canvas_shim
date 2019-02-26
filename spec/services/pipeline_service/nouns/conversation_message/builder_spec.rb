describe PipelineService::Nouns::ConversationMessage::Builder do
  include_context "pipeline_context"

  subject { described_class.new(object: noun) }

  let(:active_record_object) { ConversationMessage.create!(conversation: Conversation.create!) }
  let(:noun) { PipelineService::Nouns::Base.new(active_record_object)}

  it 'Return an attribute hash of the noun' do
    expect(subject.call).to include( { 'id' => active_record_object.id } )
  end
end
