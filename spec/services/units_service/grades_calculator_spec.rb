
describe UnitsService::GradesCalculator do
  let(:unit) { double('unit', id: 1) }
  let(:course) { double('course') }
  let(:submissions) { [checkpoint_submission, discussion_group_submission] }
  let(:checkpoint_submission) { double(:submission, excused?: false, score: 70) }
  let(:discussion_group_submission) { double(:submission, excused?: false, score: 50) }
  let(:checkpoint_assignment) { double(:assignment, assignment_group: 'checkpoints') }
  let(:discussion_assignment) { double(:assignment, assignment_group: 'discussion_groups') }

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
    # SCENARIO
    # There are 2 assignments in a Unit:
    # Checkpoint 1 – 100pts
    # Discussion 1 – 100pts
    # The Checkpoint category is worth 20% of the student’s overall grade
    # The Discussion category is worth 10% of the student’s overall grade
    # The student scored 70% on Checkpoint 1, and 50% on Discussion 1
    # Their Unit Grade would be calculated using the following:

    it 'works' do
      expect(subject.call).to eq({1=>63.33})
      subject.call
    end
  end
end
