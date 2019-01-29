describe PipelineService::Serializers::Conversation do
  include_context "pipeline_context"
  subject { described_class.new(object: conversation_model) }
  let(:conversation_model) { Conversation.create }

  it 'calls the canvas api for a conversation' do
    expect(subject.call).to eq( { id: conversation_model.id }.to_json )
  end
end
