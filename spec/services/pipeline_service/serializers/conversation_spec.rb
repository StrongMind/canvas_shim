describe PipelineService::Serializers::Conversation do
  include_context "pipeline_context"
  subject { described_class.new(object: noun) }

  let(:noun) { PipelineService::Models::Noun.new(conversation_model) }
  let(:conversation_model) { Conversation.create }

  it 'returns an attribute hash for the noun' do
    expect(subject.call).to eq( { "id" => conversation_model.id } )
  end

  it 'returns an empty hash if the conversation can not be found' do
    conversation_model.destroy
    expect(subject.call).to eq( {} )
  end
end
