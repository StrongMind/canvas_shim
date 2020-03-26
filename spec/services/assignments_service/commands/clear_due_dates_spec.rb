describe AssignmentsService::Commands::ClearDueDates do
  include_context "stubbed_network"
  subject { described_class.new(course: course) }

  subject { described_class.new(course: course) }

  let(:start_at) { Date.parse("Mon Nov 26 2018") }
  let(:end_at)   { start_at + 7.days }

  let(:course) do
    Course.create()
  end

  let(:assignment) { Assignment.create(course: course, due_at: Date.parse("Mon Nov 29 2018")) }

  it "Clears the date" do
    subject.call
    expect(course.assignments.any?(&:due_at)).to be false
  end
end