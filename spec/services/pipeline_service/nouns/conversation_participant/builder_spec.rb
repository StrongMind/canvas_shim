describe PipelineService::Nouns::ConversationParticipant::Builder do
  include_context "pipeline_context"

  subject { described_class.new(object: noun) }

  let(:conversation_participant_model) { ConversationParticipant.create(conversation_id: 5) }

  let(:noun) { PipelineService::Nouns::Base.new(conversation_participant_model) }

  it 'Return a json hash of the noun' do
    expect(subject.call).to include( "id" => conversation_participant_model.id )
  end
end
