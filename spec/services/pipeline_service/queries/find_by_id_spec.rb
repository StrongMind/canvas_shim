describe PipelineService::Queries::FindByID do
    include_context 'pipeline_context'
    
    subject { described_class }
    let(:conversation) { Conversation.create }
    let(:noun) { PipelineService::Models::Noun.new(conversation) }
    
    it 'returns a ruby hash of the object' do
        expect(subject.query(noun))
            .to eq(conversation.as_json(include_root: false))
    end
end