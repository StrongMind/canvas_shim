describe StudentEnrollment do
  let(:assignment) { Assignment.create }
  let(:course) { Course.create(assignments: [assignment]) }
  let(:command) { double("Command", perform: nil)}
  let(:user) { User.create }

  it 'publishes pipeline events' do
    expect(PipelineService::Events::HTTPClient).to receive(:post)
    described_class.create(course: course, user: user)
  end
end
