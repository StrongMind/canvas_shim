describe PipelineService::Queries::FindByID do
    include_context 'pipeline_context'
    
    subject { described_class }
    let(:conversation) { Conversation.create }
    
    it 'returns a ruby hash of the object' do
        expect(subject.query(conversation))
            .to eq(conversation.as_json(include_root: false))
    end
end