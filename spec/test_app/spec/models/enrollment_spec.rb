describe Enrollment do
  let(:assignment) { Assignment.create }
  let(:course) { Course.create(assignments: [assignment]) }
  let(:command) { double("Command", perform: nil)}


  it 'calls when created' do
    expect(AssignmentsService::Commands::SetEnrollmentAssignmentDueDates).to receive(:new).and_return(command)
    described_class.create(course: course)
  end


  it 'will run in the background' do
    expect(Delayed::Job).to receive(:enqueue)
    described_class.create(course: course)
  end
end
