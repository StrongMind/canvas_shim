describe PipelineService::Models::Noun do
    include_context('pipeline_context')

    let(:conversation) { Conversation.create }
    let(:teacher_enrollment) { TeacherEnrollment.new}
    
    let(:conversation_noun) { described_class.new(conversation) }
    let(:teacher_enrollment_noun) { described_class.new(teacher_enrollment) }


    describe '#name' do
        it 'uses the passed in class name as the name' do
            expect(conversation_noun.name).to eq conversation.class.to_s
        end

        it 'should be enrollment for all subtypes' do
            expect(teacher_enrollment_noun.name).to eq 'Enrollment'
        end
    end

    describe '#id' do
        it 'uses the passed in object id' do
            expect(conversation_noun.id).to eq conversation.id
        end
    end
end