describe PipelineService::Serializers::ConversationParticipant do
  include_context "pipeline_context"

  subject { described_class.new(object: conversation_participant_model) }

  let(:conversation_participant_model) { ConversationParticipant.create }
  let(:api_instance) { double('api_instance') }

  before do
    allow(Pandarus::Client).to receive(:new).and_return(api_instance)
  end

  it 'calls the canvas api for a conversation_participant' do
    expect(JSON.parse(subject.call)).to include( "id" => conversation_participant_model.id )
  end
end
