describe PipelineService::V2::Payload do
  include_context 'stubbed_network'
  let(:course) { Course.create() }
  let(:user) { User.create() }
  let(:assignment) { create(:assignment, :with_assignment_group, course: course) }
  let(:submission) { Submission.create(assignment: assignment, user: user) }


  it 'does not log' do
    expect(Logger).to_not receive(:new)
    described_class.new(object: PipelineService::V2::Noun.new(
      PageView.new)).call
  end

  it 'adds additional identifiers to submissions' do
    res = described_class.new(object: PipelineService::V2::Noun.new(submission)).call
    expect(res[:identifiers]).to eq ({
        :assignment_id => assignment.id,
        :course_id => course.id,
        :id => submission.id,
      })
  end
end
