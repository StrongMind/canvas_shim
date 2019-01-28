describe PipelineService::Serializers::Conversation do
  subject { described_class.new(object: conversation_model) }
  let(:conversation_model) { double('Conversation', id: 1) }
  let(:api_instance) { double('api_instance') }

  before do
    allow(Pandarus::Client).to receive(:new).and_return(api_instance)
  end

  it 'calls the canvas api for a conversation' do
    expect(api_instance).to receive(:get_single_conversation).with(conversation_model.id)
    subject.call()
  end
end
