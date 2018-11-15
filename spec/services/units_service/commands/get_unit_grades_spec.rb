describe UnitsService::Commands::GetUnitGrades do
  let(:course) { double('course', assignment_groups: []) }
  let(:user) { double('user') }
  let(:query_instance) { double('query instance', query: nil) }

  subject { described_class.new(course: course, student: user) }

  before do
    allow(UnitsService::Queries::GetSubmissions).to receive(:new).and_return(query_instance)
    allow(subject).to receive(:calculate_grades).and_return(23 => 54)
  end

  it 'returns the calculator results' do
    expect(subject.call).to eq(23 => 54)
  end
end
