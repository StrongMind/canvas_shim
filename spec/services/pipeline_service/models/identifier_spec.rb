describe PipelineService::Models::Identifier do
    let(:assignment) { double('Assignment', context_id: 6) }
    let(:user) { double('User') }
    let(:conversation) { double('Conversation', id: 1) }
    let(:conversation_participant) { double('ConversationParticipant', conversation_id: 5, id: 1) }
    let(:course) { double('Course') }
    
    describe '#to_a' do
        it 'allows us to specify a field' do
            expect(described_class.new(:conversation_id).to_a(conversation_participant)).to eq([:conversation_id, 5])
        end
        
        it 'allows us to alias the field' do
            subject = described_class.new(:context_id, alias: :course_id)
            expect(subject.to_a(assignment)).to eq([:course_id, 6])
        end
    end

    describe '#to_h' do
        it do
            subject = described_class.new(:context_id, alias: :course_id)
            expect(subject.to_h).to eq(context_id: :course_id)
        end
    
    end
end