describe AssignmentsService::Commands::HandleOverrides do
  include_context 'stubbed_network'

  context "empty overrides"
  
  describe "#call" do
    let(:due_at) { Time.now.utc }
    let(:assignment) { Assignment.create(only_visible_to_overrides: true) }
    let!(:assignment_override) { AssignmentOverride.create(assignment: assignment, due_at: 2.days.ago) }
    subject { described_class.new(assignment: assignment, due_at: due_at) }

    context 'has unassign' do
      it "resets the date of the override" do
        subject.call
        expect(assignment_override.reload.due_at).to eq(due_at)
      end

      context 'clear due dates' do
        subject { described_class.new(assignment: assignment, due_at: nil) }

        it "sets due_at to nil" do
          subject.call
          expect(assignment_override.reload.due_at).to be nil
        end
      end
    end
    

    context 'does not have unassign' do
      let!(:assignment) { Assignment.create(only_visible_to_overrides: false) }

      it "Deletes the override" do
        subject.call
        expect(assignment.reload.assignment_overrides.empty?).to be true
      end
    end

    context "empty overrides" do
      let!(:assignment) { Assignment.create(assignment_overrides: []) }
      
      it "early returns" do
        expect(assignment).not_to receive(:only_visible_to_overrides)
        subject.call
      end
    end
  end
end