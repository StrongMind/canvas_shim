describe PipelineService::Helpers::AdditionalIdentifiers do
    include_context "pipeline_context"

    subject { described_class }
    let(:conversation) { Conversation.create }
    let(:instance) { ConversationParticipant.create(conversation: conversation) }
    
    let(:additional_identifiers) {
        subject.call(
            instance: instance, 
            fields: [PipelineService::Models::Identifier.new(:conversation_id)]
        )
    }

    before do
        allow(PipelineService::HTTPClient).to receive(:post)
        allow(PipelineService::PipelineClient).to receive(:post)
    end

    it 'returns the id' do
        expect(additional_identifiers).to eq(:conversation_id => conversation.id)
    end

    context 'aliasing' do
        let(:instance) { Assignment.create(context: course) }
        let(:course) { Course.create }

        let(:additional_identifiers) do
            subject.call(
                instance: instance, 
                fields: [ 
                    PipelineService::Models::Identifier.new(:context_id, alias: :course_id)
                ]
            )
        end    

        it 'returns the field and value' do
            expect(additional_identifiers).to eq(:course_id => course.id)
        end
    end
end
