describe ConversationMessage do
    include_context "stubbed_network"
    describe '#delete' do
        it 'should publish the delete to the pipeline' do
            ConversationMessage.create
            expect(subject).to receive(:publish_as_v2_if_conversation_id)
            subject.destroy
        end
    end
end