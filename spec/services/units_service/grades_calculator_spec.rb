
describe UnitsService::GradesCalculator do
  let(:unit) { double('unit', id: 1) }
  let(:course) { double('course') }
  let(:submissions) { [checkpoint_submission, discussion_group_submission] }
  let(:checkpoint_submission) { double(:submission, excused?: false, score: 70, assignment: checkpoint_assignment) }
  let(:discussion_group_submission) { double(:submission, excused?: false, score: 50, assignment: discussion_assignment) }
  let(:checkpoint_assignment_group) { double(:checkpoint_assignment_group, name: 'checkpoints') }
  let(:discussion_assignment_group) { double(:checkpoint_assignment_group, name: 'discussion_groups') }
  let(:checkpoint_assignment) { double(:assignment, assignment_group: checkpoint_assignment_group) }
  let(:discussion_assignment) { double(:assignment, assignment_group: discussion_assignment_group) }

  let(:unit_submissions) do
    result = {}
    result[unit] = submissions
    result
  end

  subject { described_class.new(unit_submissions, course) }

  before do
    allow(subject).to receive(:category_weights).and_return(
      {
        "checkpoints" => 0.2,
        "discussion_groups" => 0.1
      }
    )
  end

  describe '#call' do
    # 70% average checkpoint grade, weighted at 20% (divided by a sum category weight of 30%)
    # 70 * (20/30)  = 46.667
    # +
    # 50% average discussion grade, weighted at 10% (divided by a sum category weight of 30%)
    # 50 * (10/30) = 16.667
    # Then, you add the categories:
    # 46.667 + 16.667 = 63.33% Unit Grade for the student

    it 'works' do
      expect(subject.call[1]).to be_within(0.1).of(63.33)
      subject.call
    end
  end
end
