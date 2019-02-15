describe PipelineService::Models::Noun do
    include_context('pipeline_context')

    let(:conversation) { Conversation.create }
    let(:submission) { Submission.create(assignment: assignment) }
    let(:assignment) { Assignment.create }
    let(:deleted_conversation) { Conversation.create() }
    let(:teacher_enrollment) { TeacherEnrollment.new}
    let(:conversation_noun) { described_class.new(conversation) }
    let(:deleted_conversation_noun) { described_class.new(deleted_conversation) }
    let(:teacher_enrollment_noun) { described_class.new(teacher_enrollment) }
    let(:unit_grades) { PipelineService::Nouns::UnitGrades.new(submission) }
    let(:unit_grades_noun) { described_class.new(unit_grades) }

    let(:changes) { {'workflow_state' => ['active', 'completed']} }

    before do
        allow(deleted_conversation).to receive('workflow_state').and_return 'deleted'
        allow(deleted_conversation).to receive('state').and_return 'deleted'
        allow(conversation).to receive(:changes).and_return(changes)
        class_double("PipelineService::Serializers::Enrollment").as_stubbed_const
    end

    describe '#name' do
        it 'uses the passed in class name as the name' do
            expect(unit_grades_noun.name).to eq 'unit_grades'
        end
    end

    describe '#id' do
        it 'uses the passed in object id' do
            expect(conversation_noun.id).to eq conversation.id
        end
    end

    describe '#changes' do
        it 'uses the passed in object changes' do
            expect(conversation_noun.changes).to eq changes
        end
    end

    describe '#destroyed?' do
        it 'true if state is "deleted"' do
            expect(deleted_conversation_noun.destroyed?).to eq true
        end
    end

    describe '#noun_class' do
        it 'returns an active record class so we can query' do
            expect(conversation_noun.noun_class).to eq Conversation
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