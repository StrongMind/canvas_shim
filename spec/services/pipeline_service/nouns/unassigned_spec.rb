describe PipelineService::Nouns::Unassigned do
  include_context 'stubbed_network'
  let(:course) { Course.create }
  let(:assignment) {Assignment.create(course: course)}
  subject { described_class.new(assignment) }

    it "has the correct assignment" do
      expect(subject.assignment).to eq(assignment)
    end

  end
