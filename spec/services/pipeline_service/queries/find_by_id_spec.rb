describe PipelineService::Queries::FindByID do
    include_context 'pipeline_context'
    
    subject { described_class }
    let(:conversation)  { Conversation.create }
    let(:noun)          { PipelineService::Nouns::Base.build(conversation) }
    let(:builder)       { PipelineService::Nouns::Conversation::Builder.new }
    
    it 'returns a ruby hash of the object' do
        builder.object = conversation
        expect(subject.query(builder.class, noun))
            .to eq('id' => conversation.id)
    end
end