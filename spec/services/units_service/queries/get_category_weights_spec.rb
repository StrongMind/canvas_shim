describe UnitsService::Queries::GetCategoryWeights do
  let(:assignment_group) { AssignmentGroup.create(name: 'discussion_groups', group_weight: 4) }
  let(:course) { Course.create(assignment_groups: [assignment_group]) }
  subject { described_class.new(course) }
  describe '#query' do
    it 'works' do
      expect(subject.query).to eq({"discussion_groups" => 4})
    end
  end
end
