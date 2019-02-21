describe PipelineService::Helpers::AdditionalIdentifiers do
    subject { described_class }
    let(:conversation) { Conversation.create }
    let(:instance) { ConversationParticipant.create(conversation: conversation) }
    let(:additional_identifiers) {
        subject.call(
            instance: instance, 
            fields: [:conversation_id]
        )
    }

    it 'returns the instance' do
        expect(additional_identifiers).to eq(:conversation_id => conversation.id)
    end
end