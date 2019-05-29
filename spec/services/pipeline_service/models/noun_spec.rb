describe PipelineService::Models::Noun do
    include_context('stubbed_network')

    let(:user) { User.create }
    let(:submission) { Submission.create(assignment: assignment, user: user) }
    let(:submission_noun) { described_class.new(submission) }
    let(:course) { Course.create }
    let(:assignment) { Assignment.create(course: course) }
    let(:deleted_conversation) { Conversation.create() }
    let(:teacher_enrollment) { TeacherEnrollment.new }
    let(:teacher_enrollment_noun) { described_class.new(teacher_enrollment)}
    let(:conversation_noun) { described_class.new(conversation) }
    let(:deleted_conversation_noun) { described_class.new(deleted_conversation) }

    let(:unit_grades) { PipelineService::Nouns::UnitGrades.new(submission) }
    let(:unit_grades_noun) { described_class.new(unit_grades) }
    let(:changes) { {'workflow_state' => ['active', 'completed']} }
    let(:conversation) { Conversation.create }
    let(:conversation_participant_noun) { described_class.new(conversation_participant) }
    let(:conversation_participant) { ConversationParticipant.create(conversation: conversation) }
    let(:page_view) { PageView.create }
    let(:page_view_noun) { described_class.new(page_view) }

    before do
        allow(conversation).to receive(:try).with(:workflow_state).and_return(nil)
        allow(conversation).to receive(:try).with(:destroyed?).and_return(false)
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

    describe '#primary_key' do
      it 'returns a custom primary_key' do
        expect(page_view_noun.primary_key).to eq 'request_id'
      end

      it 'returns a standard AR primary key' do
        expect(conversation_noun.primary_key).to eq 'id'
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

    describe '#status' do
        it 'can be nil' do
            expect(conversation_noun.status).to be_nil
        end

        it 'matches the workflow state' do
            allow(conversation).to receive(:try).with(:workflow_state).and_return('active')
            expect(conversation_noun.status).to eq 'active'
        end

        it 'can be deleted' do
            expect(deleted_conversation_noun.status).to eq 'deleted'
        end
    end

    describe '#noun_class' do
        it 'returns an active record class so we can query' do
            expect(conversation_noun.noun_class).to eq Conversation
        end
    end

    describe '#fetch' do
        it 'returns a new instance fetched from the database' do
            submission.update(workflow_state: 'newstate')
            new_noun = submission_noun.fetch
            expect(new_noun.status).to eq 'newstate'
        end
    end

    describe '#valid?' do
        it 'is valid if all of the additional ids are present' do
            expect(submission_noun).to be_valid
        end

        it 'is not valid if any of the additional ids are missing' do
            expect(described_class.new(Submission.new(assignment: Assignment.new(course: Course.new)))).to_not be_valid
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

    describe '#additional_identifiers' do
        it 'contains required linking ids' do
            expect(
                conversation_participant_noun.additional_identifiers
            ).to eq( conversation_id: conversation.id )
        end

        it 'works with a submission' do
            noun = PipelineService::Models::Noun.new(submission)
            expect(noun.additional_identifiers).to eq(
                :assignment_id => assignment.id,
                :course_id => course.id
            )
        end

        context 'synthetic nouns' do
            let(:context_module_progression) { double('context module progression', id: 1, context_module: double('context module', context: course), user: user, class: double('myclass', primary_key: 'id')) }
            let(:noun) { PipelineService::Nouns::CourseProgress.new(context_module_progression) }
            it do
              expect(noun.additional_identifiers).to eq({course_id: course.id, user_id: user.id})
            end
        end
    end
end
