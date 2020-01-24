describe AssignmentsService::Queries::AssignmentsWithDueDates do
  include_context "stubbed_network"
  let(:course) { Course.create(assignments: [assignment]) }
  let!(:context_module) { ContextModule.create(course: course, context_type: 'Course', name: 'Unit 1', context: course, workflow_state: 'active') }
  let!(:content_tag) { ContentTag.create(content_type: 'Assignment', assignment: assignment, context_module: context_module)}
  let(:assignment) { Assignment.create }
  subject { described_class.new(course: course) }
  describe '#query' do
    it 'returns assignments' do
      expect(subject.query).to eq [assignment]
    end
  end
end
