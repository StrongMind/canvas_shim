describe ConversationMessage do
    include_context "stubbed_network"
    describe '#delete' do
        it 'should publish the delete to the pipeline' do
            ConversationMessage.create
            expect(PipelineService).to receive(:publish)
            subject.destroy
        end
    end
end