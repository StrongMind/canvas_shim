describe Enrollment do
  include_context "stubbed_network"
  let(:assignment) { Assignment.create }
  let(:course) { Course.create(assignments: [assignment]) }
  let(:command) { double("Command", perform: nil)}
  let(:user) { User.create }

  it 'calls when created' do
    expect(AssignmentsService::Commands::SetEnrollmentAssignmentDueDates).to receive(:new).and_return(command)
    described_class.create(course: course, user: user)
  end


  it 'will run in the background' do
    expect(Delayed::Job).to receive(:enqueue)
    described_class.create(course: course, user: user)
  end
end
