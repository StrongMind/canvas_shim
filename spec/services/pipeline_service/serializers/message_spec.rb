describe PipelineService::Serializers::Message do
  include_context "pipeline_context"

  subject { described_class.new(object: message_model) }

  let(:message_model) { Message.create }

  it 'calls the canvas api for a message' do
    expect(JSON.parse(subject.call)).to include( { 'id' => message_model.id } )
  end
end
