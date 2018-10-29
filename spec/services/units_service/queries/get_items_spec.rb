describe UnitsService::Queries::GetItems do
  let(:course) { Course.new(context_modules: [context_module]) }
  let(:context_module) { ContextModule.new(content_tags: [content_tag]) }
  let(:content_tag) { ContentTag.new(content: assignment) }
  let(:assignment) { Assignment.new }

  subject { described_class.new(course: course) }

  it do
    subject.query
    # expect(subject.query).to eq course
  end
end
