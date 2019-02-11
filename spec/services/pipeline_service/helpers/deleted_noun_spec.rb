describe PipelineService::Helpers::DeletedNoun do
    include_context('pipeline_context')

    let(:conversation) { Conversation.create }
    subject { described_class.new(conversation) }

    describe '#name' do
        it 'uses the passed in class name as the name' do
            expect(subject.name).to eq conversation.class.to_s
        end
    end

    describe '#id' do
        it 'uses the passed in object id' do
            expect(subject.id).to eq conversation.id
        end
    end
end