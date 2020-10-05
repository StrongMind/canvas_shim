describe AssignmentsService::Queries::AssignmentsWithDueDates do
  include_context "stubbed_network"
  let(:course) { Course.create(assignments: [assignment]) }
  let!(:quiz) { Quizzes::Quiz.create }
  let!(:context_module) { ContextModule.create(course: course, context_type: 'Course', name: 'Unit 1', context: course, workflow_state: 'active') }
  let!(:content_tag) { ContentTag.create(content_type: 'Assignment', assignment: assignment, context_module: context_module)}
  let!(:content_tag_2) { ContentTag.create(content_type: 'DiscussionTopic', assignment: dt.assignment, context_module: context_module)}
  let!(:content_tag_3) { ContentTag.create(content_type: 'Quizzes::Quiz', content_id: quiz.id, context_module: context_module)}
  let(:assignment) { Assignment.create }
  let(:assignment_2) { Assignment.create }
  let(:dt) { DiscussionTopic.create(assignment: assignment) }
  subject { described_class.new(course: course) }

  describe '#query' do
    it 'returns assignments' do
      expect(subject.query).to eq [assignment, assignment, quiz]
    end

    context 'other type' do
      let!(:content_tag_3) { ContentTag.create(content_type: 'ImaginaryShaw', content_id: quiz.id, context_module: context_module)}

      it 'returns assignments' do
        expect(subject.query).not_to include quiz
      end
    end

    context 'deleted module' do
      before do
        context_module.update(workflow_state: 'deleted')
      end

      it "Does not return assignments" do
        expect(subject.query).to eq []
      end
    end
  end
end
