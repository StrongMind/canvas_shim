describe AssignmentsService::Commands::ClearDueDates do
  include_context "stubbed_network"
  subject { described_class.new(course: course) }

  let(:start_at) { Date.parse("Mon Nov 26 2018") }
  let(:end_at)   { start_at + 7.days }

  let(:course) do
    Course.create()
  end

  let!(:assignment) { Assignment.create(course: course, due_at: Date.parse("Mon Nov 29 2018")) }

  it "Clears the date" do
    subject.call
    expect(course.assignments.any?(&:due_at)).to be false
  end

  describe "#perform" do
    it "updates workflow state to failed on error" do
      allow(subject).to receive(:call).and_raise("Boom")
      subject.send(:perform)
      expect(subject.send(:progress).workflow_state).to eq("failed")
    end

    it "updates progress completion" do
      subject.perform
      expect(subject.send(:progress).completion).to eq(100)
    end

    context "4 assignments" do
      before do
        3.times do
          Assignment.create(course: course, due_at: Date.parse("Mon Nov 29 2018"))
        end
      end

      it "calculates the completion four times" do
        progress = subject.send(:progress)
        expect(progress).to receive(:calculate_completion!).exactly(4).times
        subject.perform
      end
    end
  end
end