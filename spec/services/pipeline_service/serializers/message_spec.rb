describe PipelineService::Serializers::Message do
  include_context "pipeline_context"

  subject { described_class.new(object: message_model) }

  let(:message_model) { Message.create }
  let(:api_instance) { double('api_instance') }

  before do
    allow(Pandarus::Client).to receive(:new).and_return(api_instance)
  end

  it 'calls the canvas api for a message' do
    expect(subject.call).to eq( { id: message_model.id }.to_json )
  end
end
