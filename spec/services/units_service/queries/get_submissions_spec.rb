describe UnitsService::Queries::GetSubmissions do
  let(:user) { User.create }
  let(:course) { Course.create }
  let(:submission) { Submission.create(user: user) }
  let(:assignment) { Assignment.create(submissions: [submission]) }
  let(:content_tag) { ContentTag.create(content: assignment) }

  let(:query_result) do
    result = {}
    result[ContextModule.new] = [content_tag]
    result
  end

  let(:get_items_instance) { double('get items query', query: query_result) }

  subject { described_class.new(student: user, course: course) }

  before do
    allow(UnitsService::Queries::GetItems).to receive(:new).and_return(get_items_instance)
  end

  it do
    subject.query
    # expect(subject.query).to eq course
  end
end
