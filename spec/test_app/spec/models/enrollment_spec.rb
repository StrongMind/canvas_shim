describe Enrollment do
  let(:assignment) { Assignment.create }
  let(:course) { Course.create(assignments: [assignment]) }
  let(:command) { double("Command", perform: nil)}
  subject { described_class.new(course: course) }

  it 'calls the if start_at is changed' do
    expect(AssignmentsService::Commands::SetEnrollmentAssignmentDueDates).to receive(:new).and_return(command)
    subject.update(start_at: Time.now)
  end

  it 'will not run if start_at is not changed' do
    expect(AssignmentsService::Commands::SetEnrollmentAssignmentDueDates).to_not receive(:new)
    subject.save
  end

  it 'will run in the background' do
    expect(Delayed::Job).to receive(:enqueue)
    subject.update(start_at: Time.now)
  end
end
