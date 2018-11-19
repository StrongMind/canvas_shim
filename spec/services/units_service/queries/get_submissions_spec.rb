describe UnitsService::Queries::GetSubmissions do
  let(:student) { User.create(course: course) }
  let(:course)  { Course.create(context_modules: [unit]) }
  let(:submission) { Submission.create!(user: student, assignment: assignment) }
  let(:assignment) { Assignment.create(course: course, published: true) }
  let(:unit) { ContextModule.create }
  let(:item) { ContentTag.create(content: assignment) }

  let(:units_result) do
    units = {}
    units[unit] = [item]
    units
  end

  subject { described_class.new(student: student, course: course) }

  before do
    allow(subject).to receive(:units).and_return(units_result)
    allow(PipelineService).to receive(:publish)
  end

  it 'returns the unit and its submissions' do
    result = {}
    result[unit] = [submission]
    expect(subject.query).to eq result
  end

  context "with excused submission" do
    let(:submission) do
      Submission.create!(user: student, assignment: assignment)
    end

    let(:excused_submission) do
      Submission.create!(user: student, assignment: assignment, excused: true)
    end

    it 'will not return the excused submission' do
      result = {}
      result[unit] = [submission]

      expect(subject.query[unit]).to_not include(excused_submission)
    end
  end
end
