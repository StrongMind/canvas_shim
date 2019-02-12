describe PipelineService::Models::Noun do
    include_context('pipeline_context')

    let(:conversation) { Conversation.create }
    let(:deleted_conversation) { Conversation.create() }
    let(:teacher_enrollment) { TeacherEnrollment.new}
    let(:conversation_noun) { described_class.new(conversation) }
    let(:deleted_conversation_noun) { described_class.new(deleted_conversation) }
    let(:teacher_enrollment_noun) { described_class.new(teacher_enrollment) }

    before do
        allow(deleted_conversation).to receive('workflow_state').and_return 'deleted'
        allow(deleted_conversation).to receive('state').and_return 'deleted'
        class_double("PipelineService::Serializers::Enrollment").as_stubbed_const
    end

    describe '#name' do
        it 'uses the passed in class name as the name' do
            expect(conversation_noun.name).to eq conversation.class.to_s
        end
    end

    describe '#id' do
        it 'uses the passed in object id' do
            expect(conversation_noun.id).to eq conversation.id
        end
    end

    describe '#destroyed?' do
        it 'true if state is "deleted"' do
            expect(deleted_conversation_noun.destroyed?).to eq true
        end
    end

    describe '#serializer' do
        it 'Conversations' do
            expect(conversation_noun.serializer).to eq PipelineService::Serializers::Conversation
        end

        it 'TeacherEnrollments' do
            expect(teacher_enrollment_noun.serializer).to eq PipelineService::Serializers::Enrollment
        end
    end
end